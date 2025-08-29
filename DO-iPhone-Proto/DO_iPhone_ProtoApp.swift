//
//  DO_iPhone_ProtoApp.swift
//  DO-iPhone-Proto
//
//  Created by Paul Mayne on 6/3/25.
//

import SwiftUI
import TipKit

/// Main app entry point for Day One prototype with global styling
@main
struct DayOnePrototypeApp: App {
    init() {
        // Register Day One Icons font (now using local implementation)
        DayOneIconFont.register()
        
        // Configure TipKit
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
        
        // Initialize daily data from JSON
        _ = DailyDataManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
