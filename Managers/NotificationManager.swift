//
//  NotificationManager.swift
//  PantryPal
//
//  Created by sanjay kumar Bairi on 9/3/25.
//

import Foundation
import SwiftData

#if os(iOS)
import UserNotifications
#endif

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var pendingNotifications: [Any] = []
    
    private override init() {
        super.init()
    }
    
    // MARK: - Permission Management
    
    func requestNotificationPermission() async {
        #if os(iOS)
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                self.isAuthorized = granted
            }
            
            if granted {
                await scheduleDailyNotificationCheck()
            }
        } catch {
            print("Error requesting notification permission: \(error)")
        }
        #else
        // On macOS, notifications are not available
        await MainActor.run {
            self.isAuthorized = false
        }
        #endif
    }
    
    func checkNotificationStatus() async {
        #if os(iOS)
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        await MainActor.run {
            self.isAuthorized = settings.authorizationStatus == .authorized
        }
        #else
        await MainActor.run {
            self.isAuthorized = false
        }
        #endif
    }
    
    // MARK: - Daily Notification Check
    
    func scheduleDailyNotificationCheck() async {
        #if os(iOS)
        let center = UNUserNotificationCenter.current()
        
        // Remove any existing daily check notifications
        center.removePendingNotificationRequests(withIdentifiers: ["dailyExpirationCheck"])
        
        // Create daily notification trigger (runs at 9:00 AM every day)
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "PantryPal Daily Check"
        content.body = "Checking for items expiring soon..."
        content.sound = .default
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "dailyExpirationCheck",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("Daily notification check scheduled successfully")
        } catch {
            print("Error scheduling daily notification check: \(error)")
        }
        #endif
    }
    
    // MARK: - Expiration Notifications
    
    func checkAndScheduleExpirationNotifications(modelContext: ModelContext) async {
        #if os(iOS)
        let fetchDescriptor = FetchDescriptor<FoodItem>()
        
        do {
            let foodItems = try modelContext.fetch(fetchDescriptor)
            let itemsExpiringIn3Days = findItemsExpiringIn3Days(from: foodItems)
            
            for item in itemsExpiringIn3Days {
                await scheduleExpirationNotification(for: item)
            }
            
            print("Scheduled \(itemsExpiringIn3Days.count) expiration notifications")
        } catch {
            print("Error fetching food items for notification scheduling: \(error)")
        }
        #endif
    }
    
    private func findItemsExpiringIn3Days(from items: [FoodItem]) -> [FoodItem] {
        let calendar = Calendar.current
        let threeDaysFromNow = calendar.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        
        return items.filter { item in
            let itemDate = calendar.startOfDay(for: item.expirationDate)
            let targetDate = calendar.startOfDay(for: threeDaysFromNow)
            return calendar.isDate(itemDate, inSameDayAs: targetDate)
        }
    }
    
    private func scheduleExpirationNotification(for item: FoodItem) async {
        #if os(iOS)
        let center = UNUserNotificationCenter.current()
        
        // Remove any existing notifications for this item
        center.removePendingNotificationRequests(withIdentifiers: ["expiration_\(item.id.uuidString)"])
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Item Expiring Soon!"
        content.body = "Heads up! Your \(item.name) is expiring in 3 days."
        content.sound = .default
        content.badge = 1
        
        // Add item details to user info
        content.userInfo = [
            "itemId": item.id.uuidString,
            "itemName": item.name,
            "expirationDate": item.expirationDate.timeIntervalSince1970
        ]
        
        // Schedule notification for 9:00 AM on the day it expires in 3 days
        let calendar = Calendar.current
        let threeDaysFromNow = calendar.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: threeDaysFromNow)
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "expiration_\(item.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("Scheduled expiration notification for \(item.name)")
        } catch {
            print("Error scheduling expiration notification for \(item.name): \(error)")
        }
        #endif
    }
    
    // MARK: - Notification Management
    
    func removeAllPendingNotifications() async {
        #if os(iOS)
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        print("Removed all pending notifications")
        #endif
    }
    
    func removeExpirationNotification(for itemId: UUID) async {
        #if os(iOS)
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["expiration_\(itemId.uuidString)"])
        print("Removed expiration notification for item: \(itemId)")
        #endif
    }
    
    func listPendingNotifications() async -> [Any] {
        #if os(iOS)
        let center = UNUserNotificationCenter.current()
        return await center.pendingNotificationRequests()
        #else
        return []
        #endif
    }
    
    // MARK: - Pending Notifications Management
    
    func loadPendingNotifications() async {
        #if os(iOS)
        let center = UNUserNotificationCenter.current()
        let notifications = await center.pendingNotificationRequests()
        
        await MainActor.run {
            self.pendingNotifications = notifications
        }
        #else
        await MainActor.run {
            self.pendingNotifications = []
        }
        #endif
    }
    
    func clearAllNotifications() {
        #if os(iOS)
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        Task {
            await loadPendingNotifications()
        }
        #endif
    }
    
    // MARK: - Background Task Support
    
    func performBackgroundExpirationCheck(modelContext: ModelContext) async {
        await checkAndScheduleExpirationNotifications(modelContext: modelContext)
    }
}

#if os(iOS)
// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap
        let userInfo = response.notification.request.content.userInfo
        
        if let itemIdString = userInfo["itemId"] as? String,
           let itemId = UUID(uuidString: itemIdString) {
            // Navigate to the specific item or show details
            print("User tapped notification for item: \(itemId)")
        }
        
        completionHandler()
    }
}
#endif
