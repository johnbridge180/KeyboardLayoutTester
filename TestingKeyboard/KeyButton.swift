//
//  KeyButton.swift
//  TestingKeyboard
//
//  Created by John Bridge on 11/25/22.
//

import Foundation
import UIKit
class KeyButton: UIButton {
    let key_data:key_data
    //let value:String
    //let uppercase_value:String?
    var isUppercase:Bool
    init(key_data:key_data,isUppercase:Bool) {
        self.key_data=key_data
        self.isUppercase=isUppercase
        super.init(frame: CGRect(x: 0, y: 0, width: 25, height: 0))
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.borderColor=UIColor.gray.cgColor
        self.layer.borderWidth=1
        self.tintColor = .black
        //self.titleLabel?.textColor = .black
        //self.tintColor = .black
        if(key_data.value=="delete") {
            self.setImage(UIImage(systemName: "delete.left"), for: [])
        } else if(key_data.value=="numbers") {
            self.setImage(UIImage(systemName: "123.rectangle"), for: [])
        } else if(key_data.value=="symbols") {
            self.setTitle("&*^", for: [])
        } else if(key_data.value=="alphabet") {
            self.setImage(UIImage(systemName: "abc"), for: [])
        } else if(key_data.value != "shift" && key_data.value != "space") {
            self.setTitle(key_data.value, for: [])
        }
        
        setCase(isUppercase)
        self.backgroundColor = .white
        self.setTitleColor(.black, for: .normal)
        self.sizeToFit()
        //self.draw(CGRect(x: 0, y: 0, width: 25, height: 50))
    }
    
    func toggleCase() {
        setCase(!isUppercase)
    }
    
    func setCase(_ isUppercase:Bool) {
        if(key_data.uppercase != nil) {
            self.isUppercase=isUppercase
            self.setTitle(isUppercase ? key_data.uppercase : key_data.value, for: [])
        }
        if(key_data.value=="shift") {
            self.setImage(isUppercase ? UIImage(systemName: "shift.fill") : UIImage(systemName: "shift"), for: [])
            self.isUppercase = isUppercase
        }
    }
    func getValue() -> String {
        if(isUppercase) {return key_data.uppercase ?? key_data.value}
        return key_data.value
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fingerOnButtonAnimation() {
        UIView.animate(withDuration: 0.02, delay: 0, options: [.allowUserInteraction,.beginFromCurrentState], animations: {
            self.backgroundColor=UIColor.gray
        })
    }
    
    func fingerOffButtonAnimation() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction,.curveEaseOut], animations: {
            self.backgroundColor=UIColor.white
        })
    }
}
