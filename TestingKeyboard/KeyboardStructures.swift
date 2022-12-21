//
//  Keyboard.swift
//  TestingKeyboard
//
//  Created by John Bridge on 11/24/22.
//

import Foundation
struct keyboard_data: Codable {
    let name: String
    let main_keyboard: keyboard_panel?
    let numbers: keyboard_panel?
    let symbols: keyboard_panel?
}

struct keyboard_panel: Codable {
    let key_rows: [key_row]
    let start_uppercase: Bool?
    let case_sensitive: Bool? 
}

struct key_row: Codable {
    let width: Float32
    let keys: [key_data]
}

struct key_data: Codable {
    let value: String
    let uppercase: String?
    let width: Float32
}
