//
//  BlitzFlashApp.swift
//  BlitzFlash
//
//  Created by BlitzHan on 25.04.2026.
//

import SwiftUI

@main
struct BlitzFlashApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var monetization = MonetizationStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(monetization)
                .task {
                    monetization.start()
                }
        }
    }
}
