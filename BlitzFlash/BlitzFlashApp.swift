//
//  BlitzFlashApp.swift
//  BlitzFlash
//
//  Created by BlitzHan on 25.04.2026.
//

import SwiftUI

@main
struct BlitzFlashApp: App {
    @StateObject private var monetization = MonetizationStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(monetization)
                .task {
                    monetization.start()
                }
        }
    }
}
