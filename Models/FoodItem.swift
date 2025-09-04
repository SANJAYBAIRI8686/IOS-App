//
//  FoodItem.swift
//  PantryPal
//
//  Created by sanjay kumar Bairi on 9/3/25.
//

import Foundation
import SwiftData

@Model
final class FoodItem {
    var id: UUID
    var name: String
    var quantity: String
    var expirationDate: Date
    var storageLocation: StorageLocation
    var dateAdded: Date
    
    init(name: String, quantity: String, expirationDate: Date, storageLocation: StorageLocation) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.expirationDate = expirationDate
        self.storageLocation = storageLocation
        self.dateAdded = Date()
    }
}

enum StorageLocation: String, CaseIterable, Codable {
    case pantry = "Pantry"
    case fridge = "Fridge"
    case freezer = "Freezer"
    
    var icon: String {
        switch self {
        case .pantry:
            return "cabinet"
        case .fridge:
            return "thermometer.snowflake"
        case .freezer:
            return "snowflake"
        }
    }
    
    var color: String {
        switch self {
        case .pantry:
            return "brown"
        case .fridge:
            return "blue"
        case .freezer:
            return "cyan"
        }
    }
}
