//
//  AddFoodItemView.swift
//  PantryPal
//
//  Created by sanjay kumar Bairi on 9/3/25.
//

import SwiftUI
import SwiftData

struct AddFoodItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notificationManager: NotificationManager
    
    @StateObject private var apiManager = ProductAPIManager()
    
    @State private var name = ""
    @State private var quantity = ""
    @State private var storageLocation = StorageLocation.pantry
    @State private var expirationDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    
    @State private var showingBarcodeScanner = false
    @State private var showingValidationAlert = false
    @State private var showingAPIError = false
    @State private var validationMessage = ""
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            NavigationStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Section
                        headerSection
                        
                        // Form Section
                        formSection
                        
                        // Barcode Scanner Section
                        barcodeSection
                        
                        // Save Button Section
                        saveButtonSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .navigationTitle("Add Food Item")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                .sheet(isPresented: $showingBarcodeScanner) {
                    BarcodeScannerView { barcode in
                        handleBarcodeScanned(barcode)
                    }
                }
                .alert("Validation Error", isPresented: $showingValidationAlert) {
                    Button("OK") { }
                } message: {
                    Text(validationMessage)
                }
                .alert("API Error", isPresented: $showingAPIError) {
                    Button("OK") { }
                } message: {
                    Text(apiManager.errorMessage ?? "Unknown error occurred")
                }
                .onReceive(apiManager.$errorMessage) { errorMessage in
                    if errorMessage != nil {
                        showingAPIError = true
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        GlassmorphismCard {
            VStack(spacing: 20) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.orange)
                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 12) {
                    Text("Add New Item")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    Text("Fill in the details below to add a new item to your pantry")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private var formSection: some View {
        GlassmorphismCard {
            VStack(spacing: 24) {
                // Item Name
                VStack(alignment: .leading, spacing: 8) {
                    Label("Item Name", systemImage: "tag.fill")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter item name", text: $name)
                        .textFieldStyle(CustomTextFieldStyle())
                        .autocapitalization(.words)
                }
                
                // Quantity
                VStack(alignment: .leading, spacing: 8) {
                    Label("Quantity", systemImage: "scalemass.fill")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("e.g., 250g, 500ml, 1", text: $quantity)
                        .textFieldStyle(CustomTextFieldStyle())
                        .keyboardType(.default)
                }
                
                // Storage Location
                VStack(alignment: .leading, spacing: 8) {
                    Label("Storage Location", systemImage: "building.2.fill")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Picker("Storage Location", selection: $storageLocation) {
                        ForEach(StorageLocation.allCases, id: \.self) { location in
                            HStack {
                                Image(systemName: location.icon)
                                    .foregroundColor(Color(location.color))
                                Text(location.rawValue)
                            }
                            .tag(location)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Expiration Date
                VStack(alignment: .leading, spacing: 8) {
                    Label("Expiration Date", systemImage: "calendar.badge.clock")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    DatePicker("Expiration Date", selection: $expirationDate, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6).opacity(0.5))
                        )
                }
            }
        }
    }
    
    private var barcodeSection: some View {
        GlassmorphismCard {
            VStack(spacing: 20) {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                
                VStack(spacing: 12) {
                    Text("Scan Barcode")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Automatically fill in product details by scanning the barcode")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                
                AnimatedGradientButton(title: "Scan Barcode", icon: "camera.fill", isPrimary: false) {
                    showingBarcodeScanner = true
                }
            }
        }
    }
    
    private var saveButtonSection: some View {
        VStack(spacing: 16) {
            AnimatedGradientButton(title: "Save Item", icon: "checkmark.circle.fill") {
                saveItem()
            }
            .disabled(!isFormValid)
            
            if !isFormValid {
                Text("Please fill in all required fields")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func handleBarcodeScanned(_ barcode: String) {
        Task {
            let productInfo = await apiManager.fetchProductInfo(barcode: barcode)
            
            await MainActor.run {
                if let productName = apiManager.getProductName(from: productInfo) {
                    name = productName
                }
                
                if let productQuantity = apiManager.getQuantity(from: productInfo) {
                    quantity = productQuantity
                }
            }
        }
    }
    
    private func saveItem() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedQuantity = quantity.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validate input
        guard !trimmedName.isEmpty else {
            validationMessage = "Please enter an item name"
            showingValidationAlert = true
            return
        }
        
        guard !trimmedQuantity.isEmpty else {
            validationMessage = "Please enter a quantity"
            showingValidationAlert = true
            return
        }
        
        // Validate expiration date
        guard expirationDate > Date() else {
            validationMessage = "Expiration date must be in the future"
            showingValidationAlert = true
            return
        }
        
        // Create and save the new food item
        let newItem = FoodItem(
            name: trimmedName,
            quantity: trimmedQuantity,
            expirationDate: expirationDate,
            storageLocation: storageLocation
        )
        
        modelContext.insert(newItem)
        
        // Save the changes to SwiftData
        do {
            try modelContext.save()
            print("Successfully saved new item: \(trimmedName)")
        } catch {
            print("Error saving item: \(error)")
            validationMessage = "Failed to save item. Please try again."
            showingValidationAlert = true
            return
        }
        
        // Schedule notification for the new item if notifications are enabled
        if notificationManager.isAuthorized {
            Task {
                await notificationManager.checkAndScheduleExpirationNotifications(modelContext: modelContext)
            }
        }
        
        // Dismiss the sheet
        dismiss()
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    AddFoodItemView()
        .modelContainer(for: FoodItem.self, inMemory: true)
        .environmentObject(NotificationManager.shared)
}
