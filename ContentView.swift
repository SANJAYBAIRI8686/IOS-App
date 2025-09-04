//
//  ContentView.swift
//  PantryPal
//
//  Created by sanjay kumar Bairi on 9/3/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            
            TabView {
                ManageItemsView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                InventoryView()
                    .tabItem {
                        Label("Inventory", systemImage: "list.bullet")
                    }
                
                RecipeView()
                    .tabItem {
                        Label("Recipes", systemImage: "fork.knife")
                    }
            }
            .accentColor(.orange)
        }
    }
}

struct ManageItemsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var notificationManager: NotificationManager
    @Query private var foodItems: [FoodItem]
    @State private var showingAddItem = false
    @State private var showingNotificationSettings = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Quick Stats Section
                    quickStatsSection
                    
                    // Recent Items Section
                    recentItemsSection
                    
                    // Action Buttons Section
                    actionButtonsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("PantryPal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { showingNotificationSettings = true }) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddItem = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddFoodItemView()
            }
            .sheet(isPresented: $showingNotificationSettings) {
                NotificationSettingsView()
            }
        }
    }
    
    private var headerSection: some View {
        GlassmorphismCard {
            VStack(spacing: 20) {
                Image(systemName: "cabinet.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.orange)
                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 12) {
                    Text("Welcome to PantryPal!")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    Text("Manage your kitchen inventory, track expiration dates, and discover delicious recipes.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private var quickStatsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: "Total Items",
                value: "\(foodItems.count)",
                icon: "cube.box.fill",
                color: .blue
            )
            
            StatCard(
                title: "Expiring Soon",
                value: "\(itemsExpiringSoon.count)",
                icon: "exclamationmark.triangle.fill",
                color: .orange
            )
            
            StatCard(
                title: "Storage Areas",
                value: "3",
                icon: "building.2.fill",
                color: .green
            )
        }
    }
    
    private var recentItemsSection: some View {
        GlassmorphismCard {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Recent Items")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    NavigationLink(destination: InventoryView()) {
                        Text("View All")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.orange.opacity(0.1))
                            )
                    }
                }
                
                if foodItems.isEmpty {
                    emptyStateView
                } else {
                                    LazyVStack(spacing: 16) {
                    ForEach(foodItems.prefix(5)) { item in
                        RecentItemRow(item: item, onDelete: {
                            deleteRecentItem(item)
                        })
                    }
                }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
                .opacity(0.6)
            
            VStack(spacing: 8) {
                Text("No Items Yet")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Start building your pantry by adding your first item!")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 40)
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            AnimatedGradientButton(title: "Add New Item", icon: "plus.circle.fill") {
                showingAddItem = true
            }
            
            AnimatedGradientButton(title: "Notification Settings", icon: "bell.fill", isPrimary: false) {
                showingNotificationSettings = true
            }
        }
    }
    
    private var itemsExpiringSoon: [FoodItem] {
        let calendar = Calendar.current
        let sevenDaysFromNow = calendar.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        
        return foodItems.filter { item in
            item.expirationDate <= sevenDaysFromNow && item.expirationDate > Date()
        }
    }
    
    private func deleteRecentItem(_ item: FoodItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            modelContext.delete(item)
            
            do {
                try modelContext.save()
                print("Successfully deleted recent item: \(item.name)")
            } catch {
                print("Error deleting recent item: \(error)")
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        GlassmorphismCard {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                    .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 2)
                
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
    }
}

struct RecentItemRow: View {
    let item: FoodItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: item.storageLocation.icon)
                .font(.title2)
                .foregroundColor(Color(item.storageLocation.color))
                .frame(width: 35, height: 35)
                .background(
                    Circle()
                        .fill(Color(item.storageLocation.color).opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Text(item.quantity)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                Text(item.storageLocation.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(item.storageLocation.color))
                    )
                
                Text(item.expirationDate, style: .date)
                    .font(.caption)
                    .foregroundColor(expirationColor)
                    .fontWeight(.medium)
            }
            
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "trash.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
        }
    }
    
    private var expirationColor: Color {
        let daysUntilExpiry = Calendar.current.dateComponents([.day], from: Date(), to: item.expirationDate).day ?? 0
        
        if daysUntilExpiry < 0 {
            return .red
        } else if daysUntilExpiry <= 3 {
            return .orange
        } else if daysUntilExpiry <= 7 {
            return .yellow
        } else {
            return .green
        }
    }
}

struct FoodItemRow: View {
    let item: FoodItem
    
    var body: some View {
        HStack {
            Image(systemName: item.storageLocation.icon)
                .foregroundColor(Color(item.storageLocation.color))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                Text(item.quantity)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(item.storageLocation.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(item.expirationDate, style: .date)
                    .font(.caption)
                    .foregroundColor(expirationColor)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var expirationColor: Color {
        let daysUntilExpiry = Calendar.current.dateComponents([.day], from: Date(), to: item.expirationDate).day ?? 0
        
        if daysUntilExpiry < 0 {
            return .red
        } else if daysUntilExpiry <= 3 {
            return .orange
        } else if daysUntilExpiry <= 7 {
            return .yellow
        } else {
            return .green
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: FoodItem.self, inMemory: true)
        .environmentObject(NotificationManager.shared)
}
