import Foundation

final class CategoriesService {
    private var categories: [Category] = []
    
    private let networkClient = NetworkClient.shared
    
    func categories() async throws -> [Category] {
        guard let url = URL(string: Constants.baseURLString + Constants.categoriesRoute) else {
            print("Failed to create categories URL")
            throw NetworkError.invalidURL
        }
        
        let response: [CategoryResponse] = try await networkClient.request(
            url: url,
            method: .get
        )
        var categories: [Category] = []
        
        response.forEach { categoryResponse in
            categories.append(Category(from: categoryResponse))
        }
        
        self.categories = categories
        return categories
    }
    
    func categories(direction: Direction) async throws -> [Category] {
        let type = direction == .income ? "true" : "false"
        guard let url = URL(string: Constants.baseURLString + Constants.categoriesByTypeRoute(type)) else {
            print("Failed to create categories URL")
            throw NetworkError.invalidURL
        }

        let response: [CategoryResponse] = try await networkClient.request(
            url: url,
            method: .get,
            requestBody: Optional<CategoryRequest>.none
        )
        var categories: [Category] = []
        
        response.forEach { categoryResponse in
            categories.append(Category(from: categoryResponse))
        }
        
        self.categories = categories
        return categories
    }
    
    func category(for transaction: Transaction) async throws -> Category {
        guard let category = categories.first(where: { $0.id == transaction.categoryId }) else {
            throw NSError(domain: "CategoriesService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid category id"])
        }
        return category
    }
}
