//
//  NotificationSettingsView.swift
//  PantryPal
//
//  Created by sanjay kumar Bairi on 9/3/25.
//

import SwiftUI

#if os(iOS)
import UserNotifications
#endif

struct NotificationSettingsView: View {
    @EnvironmentObject var notificationManager: NotificationManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        headerSection
                        
                        // Notification Status Section
                        notificationStatusSection
                        
                        // Permission Section
                        permissionSection
                        
                        // Pending Notifications Section
                        pendingNotificationsSection
                        
                        // Actions Section
                        actionsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .navigationTitle("Notifications")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
                .onAppear {
                    #if os(iOS)
                    Task {
                        await loadPendingNotifications()
                    }
                    #endif
                }
            }
        }
    }
    
    private var headerSection: some View {
        GlassmorphismCard {
            VStack(spacing: 20) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.orange)
                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 12) {
                    Text("Notification Settings")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    Text("Manage your notification preferences and stay updated about expiring items")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private var notificationStatusSection: some View {
        GlassmorphismCard {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                    
                    Text("Current Status")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notifications")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(notificationManager.isAuthorized ? "Enabled" : "Disabled")
                            .font(.subheadline)
                            .foregroundColor(notificationManager.isAuthorized ? .green : .red)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    Image(systemName: notificationManager.isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(notificationManager.isAuthorized ? .green : .red)
                        .font(.title)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6).opacity(0.5))
                )
            }
        }
    }
    
    private var permissionSection: some View {
        GlassmorphismCard {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "hand.raised.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                    
                    Text("Permission Management")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                VStack(spacing: 16) {
                    if !notificationManager.isAuthorized {
                        AnimatedGradientButton(title: "Request Permission", icon: "bell.badge") {
                            Task {
                                await notificationManager.requestNotificationPermission()
                            }
                        }
                    }
                    
                    AnimatedGradientButton(title: "Open Settings", icon: "gear", isPrimary: false) {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                    
                    AnimatedGradientButton(title: "Refresh Status", icon: "arrow.clockwise", isPrimary: false) {
                        Task {
                            await notificationManager.requestNotificationPermission()
                        }
                    }
                }
            }
        }
    }
    
    private var pendingNotificationsSection: some View {
        GlassmorphismCard {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.purple)
                        .font(.title2)
                    
                    Text("Pending Notifications")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    #if os(iOS)
                    Text("\(notificationManager.pendingNotifications.count)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.1))
                        )
                    #endif
                }
                
                #if os(iOS)
                if notificationManager.pendingNotifications.isEmpty {
                    emptyNotificationsView
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(notificationManager.pendingNotifications.enumerated()), id: \.offset) { index, notification in
                            if let notificationRequest = notification as? UNNotificationRequest {
                                PendingNotificationRow(notification: notificationRequest)
                            }
                        }
                    }
                }
                #else
                emptyNotificationsView
                #endif
            }
        }
    }
    
    private var emptyNotificationsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
                .opacity(0.6)
            
            Text("No Pending Notifications")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("All notifications have been delivered or cleared")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
    }
    
    private var actionsSection: some View {
        VStack(spacing: 16) {
            AnimatedGradientButton(title: "Clear All Notifications", icon: "trash.fill", isPrimary: false) {
                Task {
                    await notificationManager.removeAllPendingNotifications()
                    await notificationManager.loadPendingNotifications()
                }
            }
            .disabled(notificationManager.pendingNotifications.isEmpty)
            
            #if os(iOS)
            if notificationManager.pendingNotifications.isEmpty {
                Text("No notifications to clear")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
            #endif
        }
    }
    
    #if os(iOS)
    private func loadPendingNotifications() async {
        await notificationManager.loadPendingNotifications()
    }
    #endif
}

#if os(iOS)
struct PendingNotificationRow: View {
    let notification: UNNotificationRequest
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "bell.fill")
                .foregroundColor(.orange)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(notification.content.title)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                if !notification.content.body.isEmpty {
                    Text(notification.content.body)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                if let trigger = notification.trigger as? UNCalendarNotificationTrigger {
                    Text("Scheduled for: \(trigger.nextTriggerDate()?.formatted(date: .abbreviated, time: .shortened) ?? "Unknown")")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
        )
    }
}
#endif

#Preview {
    NotificationSettingsView()
        .environmentObject(NotificationManager.shared)
}
