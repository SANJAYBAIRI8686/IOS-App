//
//  RecipeAPIManager.swift
//  PantryPal
//
//  Created by sanjay kumar Bairi on 9/3/25.
//

import Foundation

struct Recipe: Codable, Identifiable {
    let id: Int
    let title: String
    let image: String?
    let usedIngredientCount: Int
    let missedIngredientCount: Int
    let missedIngredients: [Ingredient]
    let usedIngredients: [Ingredient]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case image
        case usedIngredientCount = "usedIngredientCount"
        case missedIngredientCount = "missedIngredientCount"
        case missedIngredients = "missedIngredients"
        case usedIngredients = "usedIngredients"
    }
}

struct Ingredient: Codable, Identifiable {
    let id: Int
    let amount: Double
    let unit: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case unit
        case name
    }
}

class RecipeAPIManager: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var recipes: [Recipe] = []
    
    // Note: You'll need to get a free API key from https://spoonacular.com/food-api
    private let apiKey = "YOUR_SPOONACULAR_API_KEY"
    private let baseURL = "https://api.spoonacular.com/recipes/findByIngredients"
    
    func searchRecipes(ingredients: [String]) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            recipes = []
        }
        
        guard !apiKey.isEmpty && apiKey != "YOUR_SPOONACULAR_API_KEY" else {
            await MainActor.run {
                errorMessage = "Please add your Spoonacular API key to RecipeAPIManager.swift"
                isLoading = false
            }
            return
        }
        
        // Create ingredients string (comma-separated)
        let ingredientsString = ingredients.joined(separator: ",")
        
        // Build URL with query parameters
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "ingredients", value: ingredientsString),
            URLQueryItem(name: "number", value: "10"),
            URLQueryItem(name: "ranking", value: "2"), // Maximize used ingredients
            URLQueryItem(name: "ignorePantry", value: "true")
        ]
        
        guard let url = components?.url else {
            await MainActor.run {
                errorMessage = "Invalid URL"
                isLoading = false
            }
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run {
                    errorMessage = "Invalid response"
                    isLoading = false
                }
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                await MainActor.run {
                    errorMessage = "HTTP Error: \(httpResponse.statusCode)"
                    isLoading = false
                }
                return
            }
            
            let decoder = JSONDecoder()
            let recipeResults = try decoder.decode([Recipe].self, from: data)
            
            await MainActor.run {
                recipes = recipeResults
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                if error is DecodingError {
                    errorMessage = "Failed to parse recipe data"
                } else {
                    errorMessage = "Network error: \(error.localizedDescription)"
                }
                isLoading = false
            }
        }
    }
    
    func getRecipeImageURL(from imageString: String?) -> URL? {
        guard let imageString = imageString, !imageString.isEmpty else { return nil }
        return URL(string: imageString)
    }
}
