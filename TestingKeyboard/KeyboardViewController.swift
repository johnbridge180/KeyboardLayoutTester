//
//  KeyboardViewController.swift
//  TestingKeyboard
//
//  Created by John Bridge on 11/23/22.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
    var keyboards:[String:KeyboardView] = [:]
    var active_keyboard = ""
    var capsLockOn = false
    
    var generator = UISelectionFeedbackGenerator()
    
    var last_touched_button: KeyButton? = nil
    var last_touched_button_bounds: CGRect? = nil
    
    var dataTracker: DataTracker = DataTracker()
    
    var kb_representation: KeyboardCoordinateRepresentation = KeyboardCoordinateRepresentation()
    
    var kb_representation_changed:Bool = false
    
    var lastSeenOrientationWasPortrait:Bool = true
    
    //var orientation: UIDeviceOrientation = .portrait
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print(GConstants.keyboard_name);
        let representation = dataTracker.loadKeyboardRepresentation()
        if(representation != nil) {
            kb_representation = representation!
        }
        
        //Set custom height of keyboard (make dynamic later)
        self.view.addConstraint(NSLayoutConstraint(item: self.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200))
        
        let kdata: keyboard_data? = readLocalKeyboardJSON(name: GConstants.keyboard_name)
        if(kdata != nil) {
            print("kdata not nil\n")
            if(kdata!.main_keyboard != nil) {
                print("main_keyboard not nil\n")
                keyboards["main_keyboard"] = KeyboardView(keyboard_data: kdata!.main_keyboard!, keyboard_vc: self, start_uppercase: kdata!.main_keyboard!.start_uppercase ?? false, rect_frame: CGRect(x: 0, y: 0, width: 500, height: 200))
                keyboards["main_keyboard"]!.translatesAutoresizingMaskIntoConstraints = false
                //keyboards["main_keyboard"]!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.changeKeyboard("main_keyboard")
            } else {
                fatalError("no main_keyboard!")
            }
            if(kdata!.numbers != nil) {
                keyboards["numbers"] = KeyboardView(keyboard_data: kdata!.numbers!, keyboard_vc: self, start_uppercase: kdata!.numbers!.start_uppercase ?? false, rect_frame: view.bounds)
                keyboards["numbers"]!.translatesAutoresizingMaskIntoConstraints = false
            }
            if(kdata!.symbols != nil) {
                keyboards["symbols"] = KeyboardView(keyboard_data: kdata!.symbols!, keyboard_vc: self, start_uppercase: kdata!.symbols!.start_uppercase ?? false, rect_frame: view.bounds)
                keyboards["symbols"]!.translatesAutoresizingMaskIntoConstraints = false
            }
            
        }
        let gesture_recognizer = KeyboardGestureRecognizer(target: self, action: #selector(touchHandler(_:)))
        self.view.addGestureRecognizer(gesture_recognizer)
        generator.prepare()
        lastSeenOrientationWasPortrait = UIScreen.main.bounds.size.width<UIScreen.main.bounds.size.height
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if(active_keyboard != "") {
            self.view.addConstraints([
                NSLayoutConstraint(item: keyboards[active_keyboard]!, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: keyboards[active_keyboard]!, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: keyboards[active_keyboard]!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: keyboards[active_keyboard]!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
            ])
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillLayoutSubviews() {
        /*self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey*/
        super.viewWillLayoutSubviews()
        if(lastSeenOrientationWasPortrait != (UIScreen.main.bounds.size.width<UIScreen.main.bounds.size.height)) {
            updateCoordinateRepresentations()
            lastSeenOrientationWasPortrait = !lastSeenOrientationWasPortrait
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear() called")
        updateCoordinateRepresentations()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        /*var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }*/
        /*self.nextKeyboardButton.setTitleColor(textColor, for: [])*/
    }
    
    func updateCoordinateRepresentations() {
        if(active_keyboard != "") {
            if(UIScreen.main.bounds.size.width<UIScreen.main.bounds.size.height) {
                if(kb_representation.portrait_kb == nil) {
                    kb_representation.portrait_kb=KeyboardOrientationCoordinateRepresentation(title: GConstants.keyboard_name, isPortrait: true, bounds: self.view.bounds)
                    kb_representation_changed=true
                }
                if(active_keyboard=="main_keyboard" && kb_representation.portrait_kb?.main_keyboard_rows.count==0) {
                    kb_representation.portrait_kb?.main_keyboard_rows=DataTracker.convertRowViewsToRepresentation(keyboards[active_keyboard]!.keyboard_rows, context: self.view)
                    kb_representation_changed=true
                } else if(active_keyboard=="numbers" && kb_representation.portrait_kb?.numbers_rows.count==0) {
                    kb_representation.portrait_kb?.numbers_rows=DataTracker.convertRowViewsToRepresentation(keyboards[active_keyboard]!.keyboard_rows, context: self.view)
                    kb_representation_changed=true
                } else if(active_keyboard=="symbols" && kb_representation.portrait_kb?.symbols_rows.count==0) {
                    kb_representation.portrait_kb?.symbols_rows=DataTracker.convertRowViewsToRepresentation(keyboards[active_keyboard]!.keyboard_rows, context: self.view)
                    kb_representation_changed=true
                }
            } else {
                if(kb_representation.landscape_kb == nil) {
                    kb_representation.landscape_kb=KeyboardOrientationCoordinateRepresentation(title: GConstants.keyboard_name, isPortrait: false, bounds: self.view.bounds)
                    kb_representation_changed=true
                }
                if(active_keyboard=="main_keyboard" && kb_representation.landscape_kb?.main_keyboard_rows.count==0) {
                    kb_representation.landscape_kb?.main_keyboard_rows=DataTracker.convertRowViewsToRepresentation(keyboards[active_keyboard]!.keyboard_rows, context: self.view)
                    kb_representation_changed=true
                } else if(active_keyboard=="numbers" && kb_representation.landscape_kb?.numbers_rows.count==0) {
                    kb_representation.landscape_kb?.numbers_rows=DataTracker.convertRowViewsToRepresentation(keyboards[active_keyboard]!.keyboard_rows, context: self.view)
                    kb_representation_changed=true
                } else if(active_keyboard=="symbols" && kb_representation.landscape_kb?.symbols_rows.count==0) {
                    kb_representation.landscape_kb?.symbols_rows=DataTracker.convertRowViewsToRepresentation(keyboards[active_keyboard]!.keyboard_rows, context: self.view)
                    kb_representation_changed=true
                }
            }
            if kb_representation_changed {
                dataTracker.recordKeyboardRepresentation(kb_representation)
            }
        }
    }

    
    func keyPressed(value: String) {
        switch(value) {
            case "shift":
                keyboards[active_keyboard]?.toggleCase()
                capsLockOn=false
                break;
            case "numbers":
                changeKeyboard("numbers")
                break;
            case "symbols":
                changeKeyboard("symbols")
                break;
            case "delete":
                textDocumentProxy.deleteBackward()
                break;
            case "return":
                textDocumentProxy.insertText("\n")
                break;
            case "alphabet":
                changeKeyboard("main_keyboard")
                break;
            case "space":
                textDocumentProxy.insertText(" ")
            default:
                textDocumentProxy.insertText(value)
                if((keyboards[active_keyboard]?.keyboard_data.case_sensitive ?? false) && (keyboards[active_keyboard]?.isUppercase) ?? false && !capsLockOn) {
                    keyboards[active_keyboard]?.setCase(isUppercase: false)
                }
                break;
        }
    }
    
    func changeKeyboard(_ keyboard: String) {
        updateCoordinateRepresentations()
        if(keyboards[keyboard] != nil) {
            keyboards[active_keyboard]?.removeFromSuperview()
            
            self.view.addSubview(keyboards[keyboard]!)
            self.view.addConstraints([
                NSLayoutConstraint(item: keyboards[keyboard]!, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: keyboards[keyboard]!, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: keyboards[keyboard]!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: keyboards[keyboard]!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
            ])
            
            self.view.sizeToFit()
            active_keyboard = keyboard
            //updateCoordinateRepresentations()
        }
    }
    
    func readLocalKeyboardJSON(name: String) -> keyboard_data? {
        do {
            if let filePath = Bundle.main.path(forResource: name, ofType: "json") {
                let fileURL = URL(fileURLWithPath: filePath)
                let data = try Data(contentsOf: fileURL)
                return try JSONDecoder().decode(keyboard_data.self, from: data)
            } else {
                print("wrong file")
            }
        } catch {
            print("JSON error: \(error)")
        }
        return nil
    }
    
    @objc
    func touchHandler(_ gestureRecognizer: KeyboardGestureRecognizer) {
        print("Test: helloooo")
        if(gestureRecognizer.state == .changed) {
            guard let location: CGPoint = gestureRecognizer.samples.last?.location, let location_in_bounds = last_touched_button_bounds?.contains(location) else {
                return
            }
            print("Timestamp: \(gestureRecognizer.samples.last!.timestamp)")
            if(!location_in_bounds) {
                //last_touched_button?.fingerOffButtonAnimation()
                guard let button = getButtonAtPoint(location) else {
                    last_touched_button?.fingerOffButtonAnimation()
                    return
                }
                last_touched_button?.fingerOffButtonAnimation()
                button.fingerOnButtonAnimation()
                last_touched_button=button
                last_touched_button_bounds=button.convert(button.bounds, to: self.view)
            }
        } else if(gestureRecognizer.state == .began) {
            print("gesture began!")
            guard let location: CGPoint = gestureRecognizer.samples.last?.location, let button = getButtonAtPoint(location) else {
                return
            }
            button.fingerOnButtonAnimation()
            last_touched_button = button
            last_touched_button_bounds = button.convert(button.bounds, to: self.view)
        } else if(gestureRecognizer.state == .ended) {
            guard let last: TouchEvent = gestureRecognizer.samples.last, let first: TouchEvent = gestureRecognizer.samples.first, let button = getButtonAtPoint(last.location) else {
                last_touched_button?.fingerOffButtonAnimation()
                return
            }
            if(last_touched_button==nil) {
                button.fingerOnButtonAnimation()
                button.fingerOffButtonAnimation()
            } else if(button != last_touched_button) {
                last_touched_button?.fingerOffButtonAnimation()
            } else {
                button.fingerOffButtonAnimation()
            }
            keyPressed(value: button.getValue())
            last_touched_button=nil
            last_touched_button_bounds=nil
            var points: [CGPoint] = []
            for touch_event in gestureRecognizer.samples {
                points.append(touch_event.location)
            }
            let keypressevent = KeyPressEvent(start_timestamp: gestureRecognizer.start_timestamp, end_timestamp: gestureRecognizer.start_timestamp+(last.timestamp-first.timestamp), points: points, value: button.getValue(), isPortrait: UIScreen.main.bounds.size.width<UIScreen.main.bounds.size.height, active_keyboard: active_keyboard)
            dataTracker.writeKeyEvent(keypressevent)
        }
    }
    
    func getButtonAtPoint(_ point: CGPoint) -> KeyButton? {
        //find the row
        var row: Int = 0
        guard let key_rows = keyboards[active_keyboard]?.keyboard_rows else {
            return nil
        }
        for i in 0...key_rows.count-1 {
            let row_bounds_within_keyboard = key_rows[i].convert(key_rows[i].bounds, to: self.view)
            if(point.y<=row_bounds_within_keyboard.maxY && point.y>=row_bounds_within_keyboard.minY) {
                print("Info: Touched Row \(i)")
                row=i
                break
            }
        }
        guard let buttons = keyboards[active_keyboard]?.keyboard_rows[row].key_buttons else {
            print("Err: No buttons in row")
            return nil
        }
        for key_button in buttons {
            let key_bounds_within_keyboard = key_button.convert(key_button.bounds,to: self.view)
            if(point.x<=key_bounds_within_keyboard.maxX && point.x>=key_bounds_within_keyboard.minX) {
                return key_button
            }
        }
        return nil
    }
}
