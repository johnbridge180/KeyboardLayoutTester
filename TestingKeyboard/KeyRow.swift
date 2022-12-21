//
//  KeyRow.swift
//  TestingKeyboard
//
//  Created by John Bridge on 11/25/22.
//

import Foundation
import UIKit
import AVFoundation
class KeyRow: UIStackView {
    var key_buttons: [KeyButton]
    let row_data: key_row
    let keyboard_vc: KeyboardViewController
    //let height: Float = 50
    init(row_data: key_row, keyboard_vc:KeyboardViewController,start_uppercase: Bool) {
        self.row_data=row_data
        key_buttons = []
        self.keyboard_vc=keyboard_vc
        super.init(frame:CGRect(x: 0, y: 0, width: 300, height: 50))
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = .gray
        self.axis = .horizontal
        self.spacing=0
        self.alignment = .center
        self.distribution = .fill

        for i in 0...row_data.keys.count-1 {
            let button: KeyButton = KeyButton(key_data: row_data.keys[i],isUppercase: start_uppercase)
            self.addArrangedSubview(button)
            addConstraints([
                NSLayoutConstraint(item: button,attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: CGFloat(row_data.keys[i].width/row_data.width), constant: 0)
            ])
            key_buttons.append(button)
        }
        self.sizeToFit()
        //super.init(frame: CGRect(x: superview?.frame.minX ?? 0, y: superview?.frame.minY ?? 0, width: superview?.frame.width ?? 0, height: superview?.frame.height ?? 0))
    }
    
    func toggleCase() {
        for key_button in key_buttons {
            key_button.toggleCase()
        }
    }
    
    func setCase(isUppercase: Bool) {
        for key_button in key_buttons {
            key_button.setCase(isUppercase)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
