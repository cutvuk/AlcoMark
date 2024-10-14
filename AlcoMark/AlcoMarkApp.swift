//
//  AlcoMarkApp.swift
//  AlcoMark
//
//  Created by Aleksandr Khrebtov on 14.10.2024.
//

import SwiftUI
import SwiftData

@main
struct AlcoMarkApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DrinkCategory.self,
                DrinkItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
