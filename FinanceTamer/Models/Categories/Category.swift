import Foundation

enum Direction {
    case income
    case outcome
}

struct Category: Identifiable, Hashable {
    let id: Int
    let name: String
    let emoji: Character
    let direction: Direction
}

extension Category {
    init(from categoryResponse: CategoryResponse) {
        self.id = categoryResponse.id
        self.name = categoryResponse.name
        self.emoji = Character(categoryResponse.emoji)
        self.direction = categoryResponse.isIncome ? .income : .outcome
    }
}
