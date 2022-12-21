//
//  KeyboardLayoutTesterApp.swift
//  KeyboardLayoutTester
//
//  Created by John Bridge on 11/23/22.
//

import SwiftUI

@main
struct KeyboardLayoutTesterApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
