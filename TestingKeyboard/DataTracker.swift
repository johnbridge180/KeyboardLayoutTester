//
//  DataTracker.swift
//  TestingKeyboard
//
//  Created by John Bridge on 12/5/22.
//

import Foundation
import UIKit

class DataTracker {
    let documents_url:URL // = FileManager.default.url(for: .documentDirectory, in: .userDomainMask)[0]
    let representation_file_url:URL
    let representation_file_path:String
    let keypress_data_file_url:URL
    var fileManager: FileManager
    
    init() {
        fileManager = FileManager.default
        //documents_url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        guard let documents_url_holder = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GConstants.app_group) else {
            fatalError("Couldnt locate documents url")
        }
        documents_url=documents_url_holder
        representation_file_url = documents_url.appendingPathComponent(GConstants.representation_filename)
        representation_file_path = representation_file_url.path
        keypress_data_file_url=documents_url.appendingPathComponent(GConstants.keypressdata_filename)
        var isDir: ObjCBool = true
        if(!fileManager.fileExists(atPath: documents_url.path, isDirectory: &isDir)) {
            do {
                try FileManager.default.createDirectory(at: documents_url, withIntermediateDirectories: true)
            } catch {
                print("Err: issue creating documents folder")
            }
        }
        if(!fileManager.fileExists(atPath: keypress_data_file_url.path)) {
            fileManager.createFile(atPath: keypress_data_file_url.path, contents: "".data(using: .utf8))
        }
    }
    func recordKeyboardRepresentation(_ representation: KeyboardCoordinateRepresentation) {
        do {
            let data = try JSONEncoder().encode(representation)
            fileManager.createFile(atPath: representation_file_path, contents: data)
        } catch {
            print("Err: could not convert representation of keyboard to json")
        }
    }
    func loadKeyboardRepresentation() -> KeyboardCoordinateRepresentation? {
        do {
            let data = try Data(contentsOf: representation_file_url)
            print(String(data:data,encoding: .utf8) ?? "fuh")
            return try JSONDecoder().decode(KeyboardCoordinateRepresentation.self, from: data)
        } catch {
            return nil
        }
    }
    func writeKeyEvent(_ event: KeyPressEvent) {
        if let handle = try? FileHandle(forWritingTo: keypress_data_file_url) {
            do {
                try handle.seekToEnd()
                let data = try JSONEncoder().encode(event)
                handle.write(data)
                handle.write(",\n".data(using: .utf8) ?? Data())
            } catch {
                print("Err: failed to append/write representation_file")
            }
        } else {
            print("Err: FileHandle no work")
        }
    }
    
    static func convertRowViewsToRepresentation(_ views: [KeyRow], context: UIView) -> [RowCoordinateRepresentation] {
        var row_representations: [RowCoordinateRepresentation] = []
        for row_view in views {
            row_representations.append(convertRowViewToRepresentation(row_view, context: context))
        }
        return row_representations
    }
    static func convertRowViewToRepresentation(_ view: KeyRow, context: UIView) -> RowCoordinateRepresentation {
        var key_representations: [KeyCoordinateRepresentation] = []
        for key_view in view.key_buttons {
            key_representations.append(convertKeyButtonToRepresenation(key_view, context: context))
        }
        return RowCoordinateRepresentation(bounds: view.convert(view.bounds, to: context), keys: key_representations)
    }
    static func convertKeyButtonToRepresenation(_ button: KeyButton, context: UIView) -> KeyCoordinateRepresentation {
        let bounds: CGRect = button.convert(button.bounds, to: context)
        print(bounds)
        return KeyCoordinateRepresentation(bounds: bounds, key_data: button.key_data)
    }
}

struct KeyPressEvent: Codable {
    let start_timestamp: Double
    let end_timestamp: Double
    let points: [CGPoint]
    let value: String?
    let isPortrait: Bool
    let active_keyboard: String
}

struct KeyboardCoordinateRepresentation: Codable {
    var portrait_kb: KeyboardOrientationCoordinateRepresentation? = nil
    var landscape_kb: KeyboardOrientationCoordinateRepresentation? = nil
}
struct KeyboardOrientationCoordinateRepresentation: Codable {
    let title: String
    let isPortrait: Bool
    let bounds: CGRect
    var main_keyboard_rows: [RowCoordinateRepresentation] = []
    var numbers_rows: [RowCoordinateRepresentation] = []
    var symbols_rows: [RowCoordinateRepresentation] = []
    init(title:String,isPortrait:Bool,bounds:CGRect) {
        self.title=title
        self.isPortrait=isPortrait
        self.bounds=bounds
    }
}
struct RowCoordinateRepresentation: Codable {
    let bounds: CGRect
    let keys: [KeyCoordinateRepresentation]
}
struct KeyCoordinateRepresentation: Codable {
    let bounds: CGRect
    let key_data: key_data
}
