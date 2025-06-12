import Foundation

struct Transaction {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let date: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
}

