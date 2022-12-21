<?php
error_reporting(E_ERROR | E_WARNING | E_PARSE | E_NOTICE);
$mysqli = new mysqli('localhost','root','root','keyboard_data');
$alpha_presses_filepath = "key_presses121122alpha.json";
$dvorak_presses_filepath = "key_presses12162022dvorak.json";
$qwerty_presses_filepath = "key_presses122022-2qwerty.json";
$alpha_file = fopen($alpha_presses_filepath,"r");
$linebuf;
$lines=0;
while(($linebuf=fgets($alpha_file)) !== false) {
	$json_arr = json_decode(substr($linebuf,0,strlen($linebuf)-2),true,512,JSON_NUMERIC_CHECK);
	$query = "INSERT INTO `key_presses` VALUES(".json_encode($json_arr['start_timestamp']).",".json_encode($json_arr['end_timestamp']).",\"".$mysqli->real_escape_string($json_arr['value'])."\",{$json_arr['isPortrait']},\"".$mysqli->real_escape_string($json_arr['active_keyboard'])."\",\"".json_encode($json_arr['points'])."\",1);";
	$mysqli->query($query);
	print($query."\n");
	$lines++;
}
fclose($alpha_file);
$dvorak_file = fopen($dvorak_presses_filepath,"r");
while(($linebuf=fgets($dvorak_file)) !== false) {
	$json_arr = json_decode(substr($linebuf,0,strlen($linebuf)-2),true,512,JSON_NUMERIC_CHECK);
	$query = "INSERT INTO `key_presses` VALUES(".json_encode($json_arr['start_timestamp']).",".json_encode($json_arr['end_timestamp']).",\"".$mysqli->real_escape_string($json_arr['value'])."\",{$json_arr['isPortrait']},\"".$mysqli->real_escape_string($json_arr['active_keyboard'])."\",\"".json_encode($json_arr['points'])."\",2);";
	$mysqli->query($query);
	print($query."\n");
	$lines++;
}
fclose($dvorak_file);
$qwerty_file = fopen($qwerty_presses_filepath,"r");
while(($linebuf=fgets($qwerty_file)) !== false) {
	$json_arr = json_decode(substr($linebuf,0,strlen($linebuf)-2),true,512,JSON_NUMERIC_CHECK);
	$query = "INSERT INTO `key_presses` VALUES(".json_encode($json_arr['start_timestamp']).",".json_encode($json_arr['end_timestamp']).",\"".$mysqli->real_escape_string($json_arr['value'])."\",{$json_arr['isPortrait']},\"".$mysqli->real_escape_string($json_arr['active_keyboard'])."\",\"".json_encode($json_arr['points'])."\",3);";
	$mysqli->query($query);
	print($query."\n");
	$lines++;
}
print("Read $lines lines!\n");
?>