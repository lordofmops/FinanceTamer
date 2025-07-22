import Foundation

final class CategoriesService {
    static let shared = CategoriesService()
    
    private var categories: [Category] = []
    private var incomeCategories: [Category] = []
    private var outcomeCategories: [Category] = []
    
    private let networkClient = NetworkClient.shared
    
    private init() {}
    
    func categories() async throws -> [Category] {
        if categories.isEmpty {
            return try await loadCategories()
        } else {
            return categories
        }
    }
    
    func categories(direction: Direction) async throws -> [Category] {
        switch direction {
        case .income:
            if incomeCategories.isEmpty {
                return try await loadCategories(direction: .income)
            } else {
                return incomeCategories
            }
        case .outcome:
            if outcomeCategories.isEmpty {
                return try await loadCategories(direction: .outcome)
            } else {
                return outcomeCategories
            }
        }
    }
    
    private func loadCategories() async throws -> [Category] {
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
        
        print("Categories loaded successfully")
        self.categories = categories
        return categories
    }
    
    private func loadCategories(direction: Direction) async throws -> [Category] {
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
        
        print("Categories with direction \(direction) loaded successfully")
        switch direction {
        case .income:
            self.incomeCategories = categories
        case .outcome:
            self.outcomeCategories = categories
        }
        return categories
    }
    
    func category(for transaction: Transaction) async throws -> Category {
        guard let category = categories.first(where: { $0.id == transaction.categoryId }) else {
            throw NSError(domain: "CategoriesService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid category id"])
        }
        
        print("Categories for transaction \(transaction.id) loaded successfully")
        return category
    }
}
