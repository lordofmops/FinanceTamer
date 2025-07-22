import Foundation

struct BankAccount {
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    let currency: String
    let createdAt: Date
    let updatedAt: Date
}

extension BankAccount {
    init(from bankAccountResponse: BankAccountResponse) {
        self.id = bankAccountResponse.id
        self.userId = bankAccountResponse.userId
        self.name = bankAccountResponse.name
        self.balance = bankAccountResponse.balance
        self.currency = bankAccountResponse.currency
        self.createdAt = bankAccountResponse.createdAt
        self.updatedAt = bankAccountResponse.updatedAt
    }
}
