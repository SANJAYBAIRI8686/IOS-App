//
//  RecipeView.swift
//  PantryPal
//
//  Created by sanjay kumar Bairi on 9/3/25.
//

import SwiftUI
import SwiftData

struct RecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var foodItems: [FoodItem]
    @StateObject private var recipeManager = RecipeAPIManager()
    
    @State private var selectedIngredients: Set<UUID> = []
    @State private var showingRecipes = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            NavigationStack {
                VStack {
                    if !showingRecipes {
                        // Ingredients Selection View
                        ingredientsSelectionView
                    } else {
                        // Recipes Results View
                        recipesResultsView
                    }
                }
                .navigationTitle("Recipe Finder")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    if showingRecipes {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Back to Ingredients") {
                                showingRecipes = false
                                selectedIngredients.removeAll()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var ingredientsSelectionView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Ingredients List
                ingredientsListSection
                
                // Find Recipes Button
                findRecipesSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    private var headerSection: some View {
        GlassmorphismCard {
            VStack(spacing: 20) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.orange)
                    .shadow(color: .orange.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 12) {
                    Text("Discover Delicious Recipes")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                    
                    Text("Select ingredients from your pantry to find recipes that use what you have")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private var ingredientsListSection: some View {
        GlassmorphismCard {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Select Ingredients")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(selectedIngredients.count) selected")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.1))
                        )
                }
                
                if foodItems.isEmpty {
                    emptyIngredientsView
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(sortedFoodItems) { item in
                            IngredientRow(
                                item: item,
                                isSelected: selectedIngredients.contains(item.id),
                                onToggle: { isSelected in
                                    if isSelected {
                                        selectedIngredients.insert(item.id)
                                    } else {
                                        selectedIngredients.remove(item.id)
                                    }
                                },
                                onDelete: {
                                    deleteIngredient(item)
                                }
                            )
                        }
                    }
                }
            }
        }
    }
    
    private var emptyIngredientsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
                .opacity(0.6)
            
            Text("No Ingredients Available")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Add some food items to your pantry first to discover recipes")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
    
    private var findRecipesSection: some View {
        VStack(spacing: 16) {
            AnimatedGradientButton(title: "Find Recipes", icon: "magnifyingglass") {
                findRecipes()
            }
            .disabled(selectedIngredients.isEmpty)
            
            if selectedIngredients.isEmpty {
                Text("Select at least one ingredient to find recipes")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
        }
    }
    
    private var recipesResultsView: some View {
        VStack {
            if recipeManager.isLoading {
                loadingView
            } else if recipeManager.recipes.isEmpty {
                noRecipesView
            } else {
                recipesListView
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.orange)
            
            Text("Searching for recipes...")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Finding delicious recipes using your ingredients")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var noRecipesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
                .opacity(0.6)
            
            Text("No Recipes Found")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Try selecting different ingredients or check your API key")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var recipesListView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(recipeManager.recipes) { recipe in
                    RecipeRow(recipe: recipe)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
    }
    
    private var sortedFoodItems: [FoodItem] {
        foodItems.sorted { item1, item2 in
            item1.expirationDate < item2.expirationDate
        }
    }
    
    private func findRecipes() {
        let selectedItemNames = foodItems
            .filter { selectedIngredients.contains($0.id) }
            .map { $0.name }
        
        showingRecipes = true
        
        Task {
            await recipeManager.searchRecipes(ingredients: selectedItemNames)
        }
    }
    
    private func deleteIngredient(_ item: FoodItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            modelContext.delete(item)
            
            do {
                try modelContext.save()
                print("Successfully deleted ingredient: \(item.name)")
                
                // Remove from selected ingredients if it was selected
                selectedIngredients.remove(item.id)
            } catch {
                print("Error deleting ingredient: \(error)")
            }
        }
    }
}

struct IngredientRow: View {
    let item: FoodItem
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: {
            onToggle(!isSelected)
        }) {
            HStack(spacing: 16) {
                // Selection Circle
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .orange : .gray)
                    .font(.title2)
                    .frame(width: 30)
                
                // Item Icon
                Image(systemName: item.storageLocation.icon)
                    .font(.title2)
                    .foregroundColor(Color(item.storageLocation.color))
                    .frame(width: 35, height: 35)
                    .background(
                        Circle()
                            .fill(Color(item.storageLocation.color).opacity(0.1))
                    )
                
                // Item Details
                VStack(alignment: .leading, spacing: 6) {
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
                        .font(.caption)
                        .foregroundColor(expirationColor)
                    
                    Text(daysUntilExpiryText)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(expirationColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
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
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.orange.opacity(0.1) : Color(.systemGray6).opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.orange.opacity(0.3) : Color.gray.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
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

struct RecipeRow: View {
    let recipe: Recipe
    
    var body: some View {
        GlassmorphismCard {
            HStack(spacing: 16) {
                // Recipe Image
                if let imageURL = recipe.image, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 90, height: 90)
                    .cornerRadius(12)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 90, height: 90)
                        .cornerRadius(12)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                
                // Recipe Details
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.title)
                        .font(.headline)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 16) {
                        Label("\(recipe.usedIngredientCount) used", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                            .fontWeight(.medium)
                        
                        if recipe.missedIngredientCount > 0 {
                            Label("\(recipe.missedIngredientCount) missing", systemImage: "exclamationmark.circle")
                                .foregroundColor(.orange)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                    
                    if !recipe.usedIngredients.isEmpty {
                        Text("Uses: \(recipe.usedIngredients.prefix(3).map { $0.name }.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    RecipeView()
        .modelContainer(for: FoodItem.self, inMemory: true)
}
