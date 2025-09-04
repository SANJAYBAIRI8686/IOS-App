//
//  ProductAPIManager.swift
//  PantryPal
//
//  Created by sanjay kumar Bairi on 9/3/25.
//

import Foundation

struct ProductInfo: Codable {
    let productName: String?
    let brands: String?
    let quantity: String?
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case quantity
        case imageUrl = "image_url"
    }
}

struct OpenFoodFactsResponse: Codable {
    let status: Int
    let product: ProductInfo?
    let statusVerbose: String?
    
    enum CodingKeys: String, CodingKey {
        case status
        case product
        case statusVerbose = "status_verbose"
    }
}

class ProductAPIManager: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://world.openfoodfacts.org/api/v0/product"
    
    func fetchProductInfo(barcode: String) async -> ProductInfo? {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        guard let url = URL(string: "\(baseURL)/\(barcode).json") else {
            await MainActor.run {
                errorMessage = "Invalid URL"
                isLoading = false
            }
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await MainActor.run {
                    errorMessage = "Invalid response"
                    isLoading = false
                }
                return nil
            }
            
            guard httpResponse.statusCode == 200 else {
                await MainActor.run {
                    errorMessage = "HTTP Error: \(httpResponse.statusCode)"
                    isLoading = false
                }
                return nil
            }
            
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(OpenFoodFactsResponse.self, from: data)
            
            await MainActor.run {
                isLoading = false
                
                if apiResponse.status == 0 {
                    errorMessage = "Product not found"
                } else if apiResponse.status == 1 {
                    // Product found successfully
                }
            }
            
            return apiResponse.product
            
        } catch {
            await MainActor.run {
                if error is DecodingError {
                    errorMessage = "Failed to parse product data"
                } else {
                    errorMessage = "Network error: \(error.localizedDescription)"
                }
                isLoading = false
            }
            return nil
        }
    }
    
    func getProductName(from productInfo: ProductInfo?) -> String? {
        // Try to get the best product name from available fields
        if let productName = productInfo?.productName, !productName.isEmpty {
            return productName
        }
        
        if let brands = productInfo?.brands, !brands.isEmpty {
            return brands
        }
        
        return nil
    }
    
    func getQuantity(from productInfo: ProductInfo?) -> String? {
        return productInfo?.quantity
    }
}
