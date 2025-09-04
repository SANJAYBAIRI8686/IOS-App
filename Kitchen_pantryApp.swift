//
//  PantryPalApp.swift
//  PantryPal
//
//  Created by sanjay kumar Bairi on 9/3/25.
//

import SwiftUI
import SwiftData

#if os(iOS)
import UserNotifications
#endif

@main
struct PantryPalApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
                .onAppear {
                    setupNotifications()
                }
        }
        .modelContainer(for: FoodItem.self)
    }
    
    private func setupNotifications() {
        #if os(iOS)
        // Set the notification delegate
        UNUserNotificationCenter.current().delegate = notificationManager
        
        // Request notification permission
        Task {
            await notificationManager.requestNotificationPermission()
        }
        #endif
    }
}
