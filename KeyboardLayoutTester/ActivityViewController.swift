//
//  ActivityViewController.swift
//  KeyboardLayoutTester
//
//  Created by John Bridge on 12/5/22.
//

import UIKit
import SwiftUI

struct ActivityViewController: UIViewControllerRepresentable {

    //var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let documents_url:URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GConstants.app_group)!
        let pressdata_url = documents_url.appendingPathComponent(GConstants.keypressdata_filename)
        let representation_url = documents_url.appendingPathComponent(GConstants.representation_filename)
        do {
            let data = try Data(contentsOf: pressdata_url)
            print(String(data:data,encoding: .utf8) ?? "fuh")
        } catch {
            return UIActivityViewController(activityItems: [], applicationActivities: applicationActivities)
        }
        //let fileManager = FileManager.defaultManager()
        return UIActivityViewController(activityItems: [representation_url.absoluteURL,pressdata_url.absoluteURL], applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

}
