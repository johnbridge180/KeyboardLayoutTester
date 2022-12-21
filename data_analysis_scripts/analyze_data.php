<html>
<head>
</head>
<body>
<?php
function faultsafe_average($value, $average, $average_denom) {
	if($average_denom==0) {
		return $value;
 	} 
	return ($average*$average_denom+$value)/($average_denom+1);
}

function create_keyrow($mysqli_obj, $key_jsonrow, $isPortrait, $layout_type, $active_panel) {
	$query = "";
	if($isPortrait) {
		$query = "INSERT IGNORE INTO key_analysis (key_value,layout_type,active_panel,tl_x,tl_y,br_x,br_y) VALUES (\"".$mysqli_obj->real_escape_string($key_jsonrow["key_data"]["value"])."\",{$layout_type},\"{$active_panel}\",".json_encode($key_jsonrow["bounds"][0][0]).",".json_encode($key_jsonrow["bounds"][0][1]).",".json_encode($key_jsonrow["bounds"][1][0]).",".json_encode($key_jsonrow["bounds"][1][1]).");";
	} else {
		$query = "UPDATE key_analysis SET tl_x_lkb=".json_encode($key_jsonrow["bounds"][0][0]).", tl_y_lkb=".json_encode($key_jsonrow["bounds"][0][1]).", br_x_lkb=".json_encode($key_jsonrow["bounds"][1][0]).", br_y_lkb=".json_encode($key_jsonrow["bounds"][1][1])." WHERE key_value=\"".$mysqli_obj->real_escape_string($key_jsonrow["key_data"]["value"])."\" AND layout_type={$layout_type} AND active_panel={$active_panel};";
	}
	$mysqli_obj->query($query);
}
function insert_keys($mysqli_obj,$representation_filepath,$layout_type) {
	$representation_obj = json_decode(file_get_contents($representation_filepath),true);
	$layouts = array("portrait_kb","landscape_kb");
	$panel_types = array("main_keyboard_rows","numbers_rows","symbols_rows");
	foreach($layouts as $layout) {
		foreach($panel_types as $panel_type) {
			$panel_rows = $representation_obj[$layout][$panel_type];
			foreach($panel_rows as $row) {
			    foreach($row['keys'] as $key) {
			    	create_keyrow($mysqli_obj,$key,$layout=="portrait_kb",$layout_type,$panel_type);
			    }
			}
		}
    }
}

function analyze_word($mysqli_obj, array $word, $layout_type) {
	$end = 0.0;
	$nodelete="";
	$word_value="";
	$seen_delete=false;
	$replaced=0;
	foreach($word as $row) {
		if($row["end_timestamp"]>$end)
			$end = $row["end_timestamp"];
		if($row['deleted']===true && $row['replaced_with'] != null) {
			if($row['replaced_with']['end_timestamp']>$end)
				$end=$row['replaced_with']['end_timestamp'];
			$word_value .= $row['replaced_with']['value'];
			$replaced++;
		} else if($row['deleted']===false) {
			$word_value .= $row['value'];
		}
		$nodelete .= $row['value'];
	}
	$time = $end-$word[0]["start_timestamp"];
	if($replaced<3)
	    $mysqli_obj->query("INSERT INTO words VALUES (".json_encode($word[0]['start_timestamp']).",\"".$mysqli_obj->real_escape_string($word_value)."\",".json_encode($time).",{$layout_type},\"".$mysqli_obj->real_escape_string($nodelete)."\");");
}

function analyze_keyboard_data($mysqli_obj, $layout_type, $representation_filepath) {
	$query = "SELECT * FROM key_presses WHERE layout_type=$layout_type ORDER BY start_timestamp ASC;";
    $result = $mysqli_obj->query($query);
    $seen_rows = array();
    $word = array();
    $word_index=-1;
    $word_lastpressed_time=0;
    $last_key_value="";
    $last_key_timestamp_end=0;
	while(($row=$result->fetch_assoc()) !== false) {
		if($row==null)
			break;
		$points=json_decode($row['points'],true);
		print($row['points']."\n");
		$query="SELECT * FROM key_analysis WHERE key_value=\"".$mysqli_obj->real_escape_string($row['value'])."\" AND layout_type={$layout_type};";
		$result2=$mysqli_obj->query($query);
		$db_keyrow=$result2->fetch_assoc();
		$lsuf="";
		if($row['isPortrait'] == 0)
			$lsuf="_landscape";
		if($points[count($points)-1][0]>=$db_keyrow['tl_x'] && $points[count($points)-1][1]>=$db_keyrow['tl_y'] && $points[count($points)-1][0]<=($db_keyrow['tl_x']+$db_keyrow['br_x']) && $points[count($points)-1][1]<=($db_keyrow['tl_y']+$db_keyrow['br_y'])) {
			$query="UPDATE key_analysis SET presses=".($db_keyrow['presses'.$lsuf]+1);
			if($last_key_timestamp_end != 0 && ($row['end_timestamp']-$last_key_timestamp_end)<3.0 && $last_key_value != $row['value']) {
				$query .= ", avg_timetofind=".faultsafe_average($row['end_timestamp']-$last_key_timestamp_end,$db_keyrow['avg_timetofind'],$db_keyrow['presses'.$lsuf]);
			}
			$query .= ", avg_x_down".$lsuf."=".faultsafe_average($points[0][0],$db_keyrow['avg_x_down'.$lsuf],$db_keyrow['presses'.$lsuf]).", avg_y_down".$lsuf."=".faultsafe_average($points[0][1],$db_keyrow['avg_y_down'.$lsuf],$db_keyrow['presses'.$lsuf]).", avg_x_up".$lsuf."=".faultsafe_average($points[count($points)-1][0],$db_keyrow['avg_x_up'.$lsuf],$db_keyrow['presses'.$lsuf]).", avg_y_up".$lsuf."=".faultsafe_average($points[count($points)-1][1],$db_keyrow['avg_y_up'.$lsuf],$db_keyrow['presses'.$lsuf])." WHERE key_value=\"".$mysqli_obj->real_escape_string($row['value'])."\"";
			$query .= " AND layout_type={$layout_type} AND active_panel=\"".$row["active_keyboard"]."_rows\";";
			$mysqli_obj->query($query);
			if(count($word)>0 && ($row['value']=="space" || $row['value']=="return" || ($row['value']!="delete" && count($word)>0 && ($row['start_timestamp']-$word_lastpressed_time)>6.0))) {
				analyze_word($mysqli_obj,$word,$layout_type);
				$word = array();
				$word_index=-1;
			} else if($row['value']=="delete" && count($word)>0) {
				$word[$word_index]['deleted']=true;
				$word_index--;
				$word_lastpressed_time=$row['end_timestamp'];
		    } else if($row['value']!="numbers" && $row['value']!="symbols" && $row['value']!="alphabet" && $row['value']!="shift" && $row['value']!="space" && $row['value']!="return" && $row['value']!="delete") {
		    	if($word_index < count($word)-1) {
		    		$word_index++;
		    		$word[$word_index]['replaced_with']=$row;
		    	} else {
					$row['deleted']=false;
					$row['replaced_with']=null;
					$word[] = $row;
					$word_index++;
			    }
			    $word_lastpressed_time=$row['end_timestamp'];
			}
    	}
	}
}
error_reporting(E_ERROR | E_WARNING | E_PARSE | E_NOTICE);
$mysqli = new mysqli('localhost','root','root','keyboard_data');
$alpha_representation_filepath = "example_representations/keyboard_representation121122alpha.json";
$dvorak_representation_filepath = "example_representations/keyboard_representation_dvorak.json";
$qwerty_representation_filepath = "example_representations/keyboard_representation_qwerty.json";
$alpha_id=1;
$dvorak_id=2;
$qwerty_id=3;
insert_keys($mysqli,$alpha_representation_filepath,$alpha_id);
insert_keys($mysqli,$dvorak_representation_filepath,$dvorak_id);
insert_keys($mysqli,$qwerty_representation_filepath,$qwerty_id);
//Analysis of Alphabetic Keyboard
analyze_keyboard_data($mysqli,$alpha_id,$alpha_representation_filepath);
//Analysis of Dvorak Keyboard
analyze_keyboard_data($mysqli,$dvorak_id,$dvorak_representation_filepath);
//Analysis of QWERTY Keyboard
analyze_keyboard_data($mysqli,$qwerty_id,$qwerty_representation_filepath);
?>
</body>
</html>