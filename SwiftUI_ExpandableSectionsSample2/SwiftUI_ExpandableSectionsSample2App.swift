//
//  SwiftUI_ExpandableSectionsSample2App.swift
//  SwiftUI_ExpandableSectionsSample2
//
//  Created by Yuki Sasaki on 2025/08/08.
//

import SwiftUI

@main
struct SwiftUI_ExpandableSectionsSample2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
