//
//  InventoryView.swift
//  PantryPal
//
//  Created by sanjay kumar Bairi on 9/3/25.
//

import SwiftUI
import SwiftData

struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var foodItems: [FoodItem]
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        headerSection
                        
                        // Storage Sections
                        ForEach(StorageLocation.allCases, id: \.self) { location in
                            storageSection(for: location)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .navigationTitle("Inventory")
                .navigationBarTitleDisplayMode(.large)
            }
        }
    }
    
    private var headerSection: some View {
        GlassmorphismCard {
            VStack(spacing: 16) {
                Image(systemName: "list.bullet.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                    .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
                
                VStack(spacing: 8) {
                    Text("Your Pantry Inventory")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Organized by storage location for easy management")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private func storageSection(for location: StorageLocation) -> some View {
        let itemsInLocation = foodItems.filter { $0.storageLocation == location }
        
        return GlassmorphismCard {
            VStack(alignment: .leading, spacing: 20) {
                // Section Header
                HStack {
                    Image(systemName: location.icon)
                        .font(.title2)
                        .foregroundColor(Color(location.color))
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(Color(location.color).opacity(0.1))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(location.rawValue)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("\(itemsInLocation.count) item\(itemsInLocation.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Items List
                if itemsInLocation.isEmpty {
                    emptyLocationView
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(itemsInLocation.sorted { $0.expirationDate < $1.expirationDate }) { item in
                            InventoryItemRow(item: item, onDelete: {
                                deleteItem(item)
                            })
                        }
                    }
                }
            }
        }
    }
    
    private var emptyLocationView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
                .opacity(0.6)
            
            Text("No items yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add items to start building your \(StorageLocation.pantry.rawValue.lowercased())")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
    }
    
    private func deleteItem(_ item: FoodItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            modelContext.delete(item)
            
            do {
                try modelContext.save()
                print("Successfully deleted item: \(item.name)")
            } catch {
                print("Error deleting item: \(error)")
            }
        }
    }
}

struct StorageLocationHeader: View {
    let location: StorageLocation
    let itemCount: Int
    
    var body: some View {
        HStack {
            Image(systemName: location.icon)
                .foregroundColor(Color(location.color))
                .font(.title2)
            
            Text(location.rawValue)
                .font(.headline)
                .foregroundColor(Color(location.color))
            
            Spacer()
            
            Text("\(itemCount) item\(itemCount == 1 ? "" : "s")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct InventoryItemRow: View {
    let item: FoodItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Item Icon
            Image(systemName: item.storageLocation.icon)
                .font(.title2)
                .foregroundColor(Color(item.storageLocation.color))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color(item.storageLocation.color).opacity(0.1))
                )
            
            // Item Details
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    Text(item.quantity)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.1))
                        )
                    
                    Text(item.storageLocation.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(item.storageLocation.color))
                        )
                }
            }
            
            Spacer()
            
            // Expiration Info
            VStack(alignment: .trailing, spacing: 6) {
                Text(item.expirationDate, style: .date)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(expirationColor)
                
                Text(daysUntilExpiryText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(expirationColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(expirationColor.opacity(0.1))
                    )
            }
            
            // Delete Button
            Button(action: onDelete) {
                Image(systemName: "trash.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
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
            return .red
        } else if daysUntilExpiry <= 7 {
            return .orange
        } else {
            return .green
        }
    }
    
    private var daysUntilExpiryText: String {
        let daysUntilExpiry = Calendar.current.dateComponents([.day], from: Date(), to: item.expirationDate).day ?? 0
        
        if daysUntilExpiry < 0 {
            return "Expired"
        } else if daysUntilExpiry == 0 {
            return "Today"
        } else if daysUntilExpiry == 1 {
            return "Tomorrow"
        } else if daysUntilExpiry <= 7 {
            return "\(daysUntilExpiry) days"
        } else {
            return "\(daysUntilExpiry) days"
        }
    }
}

#Preview {
    InventoryView()
        .modelContainer(for: FoodItem.self, inMemory: true)
}
