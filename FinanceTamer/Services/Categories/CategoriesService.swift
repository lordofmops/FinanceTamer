import Foundation

final class CategoriesService {
    private var categories: [Category] = [
        Category(id: 1, name: "Аренда квартиры", emoji: "🏠", direction: .outcome),
        Category(id: 2, name: "Одежда", emoji: "👔", direction: .outcome),
        Category(id: 3, name: "На собачку", emoji: "🐕", direction: .outcome),
        Category(id: 4, name: "Зарплата", emoji: "💼", direction: .income)
    ]
    
    func categories() async throws -> [Category] {
        categories
    }
    
    func categories(direction: Direction) async throws -> [Category] {
        categories.filter { $0.direction == direction }
    }
}
