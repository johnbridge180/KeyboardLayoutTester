//
//  KeyboardView.swift
//  TestingKeyboard
//
//  Created by John Bridge on 11/25/22.
//

import Foundation
import UIKit
class KeyboardView: UIStackView {
    let keyboard_data: keyboard_panel
    var keyboard_rows: [KeyRow]
    var isUppercase: Bool = true
    init(keyboard_data: keyboard_panel,keyboard_vc: KeyboardViewController,start_uppercase: Bool, rect_frame: CGRect) {
        self.keyboard_data=keyboard_data
        self.keyboard_rows=[]
        self.isUppercase=start_uppercase
        super.init(frame: rect_frame)
        /*self.addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200))*/
        //self.spacing = 50
        self.axis = .vertical
        self.alignment = .center
        self.distribution = .fillEqually
        self.translatesAutoresizingMaskIntoConstraints = false
        print("row count: \(keyboard_data.key_rows.count)")
        for row_data in keyboard_data.key_rows {
            let row_view = KeyRow(row_data: row_data, keyboard_vc: keyboard_vc, start_uppercase: start_uppercase)
           self.addArrangedSubview(row_view)
            addConstraints([
                NSLayoutConstraint(item: row_view, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0/CGFloat(keyboard_data.key_rows.count), constant: 0),
                NSLayoutConstraint(item: row_view, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: CGFloat(row_data.width/100.0), constant: 0)
            ])
            self.keyboard_rows.append(row_view)
            //self.sizeToFit()
        }
        //self.init(arra)
    }
    
    func setCase(isUppercase: Bool) {
        self.isUppercase=isUppercase
        for row_view in keyboard_rows {
            row_view.setCase(isUppercase: isUppercase)
        }
    }
    
    func toggleCase() {
        self.isUppercase = !isUppercase
        for row_view in keyboard_rows {
            row_view.toggleCase()
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
