//
//  ChineseNameSuggApp.swift
//  ChineseNameSugg
//
//  Created by ByteDance on 2025/2/14.
//

import SwiftUI

@main
struct ChineseNameSuggApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
