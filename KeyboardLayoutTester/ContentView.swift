//
//  ContentView.swift
//  KeyboardLayoutTester
//
//  Created by John Bridge on 11/23/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    private let documents_url:URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: GConstants.app_group)!
    /*private let pressdata_url = documents_url.appendingPathComponent(GConstants.keypressdata_filename)
    private let representation_url = documents_url.appendingPathComponent(GConstants.representation_filename)*/
    @State private var saveDataPushed: Bool = false
    @State private var resetDataPushed: Bool = false
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            /*List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                    } label: {
                        Text(item.timestamp!, formatter: itemFormatter)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }*/
            //Text("Select an item")
            List {
                if #available(iOS 16.0, *) {
                    ShareLink(item: documents_url.appendingPathComponent(GConstants.keypressdata_filename)) {
                        Label(GConstants.keypressdata_filename, systemImage:  "square.and.arrow.up")
                    }
                    ShareLink(item: documents_url.appendingPathComponent(GConstants.representation_filename)) {
                        Label(GConstants.representation_filename, systemImage:  "square.and.arrow.up")
                    }
                } else {
                    Button("Save Data") {
                        saveDataPushed=true
                    }.sheet(isPresented: $saveDataPushed) {
                        ActivityViewController(applicationActivities: nil)
                    }
                }
                Button("Reset Data") {
                    resetDataPushed=true
                }.sheet(isPresented: $saveDataPushed) {
                    
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
