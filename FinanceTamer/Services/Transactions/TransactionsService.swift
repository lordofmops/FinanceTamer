import Foundation

final class TransactionsService {
    static let shared = TransactionsService()
    private init() {}
    
    @Published private(set) var transactions: [Transaction] = [
        Transaction(id: 1,
                    accountId: 1,
                    categoryId: 1,
                    amount: 80000,
                    date: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-07-12T13:55:57.197Z")!,
                    comment: "Аренда",
                    createdAt: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-07-12T13:55:57.197Z")!,
                    updatedAt: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-07-12T13:55:57.197Z")!
                   ),
        Transaction(id: 2,
                    accountId: 1,
                    categoryId: 3,
                    amount: 15000,
                    date: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-07-12T13:55:57.197Z")!,
                    comment: "Ричард",
                    createdAt: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-07-12T13:55:57.197Z")!,
                    updatedAt: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-07-12T13:55:57.197Z")!
                   ),
        Transaction(id: 3,
                    accountId: 1,
                    categoryId: 3,
                    amount: 15000,
                    date: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-07-12T13:55:57.197Z")!,
                    comment: nil,
                    createdAt: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-07-12T13:55:57.197Z")!,
                    updatedAt: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-07-12T13:55:57.197Z")!
                   ),
        Transaction(id: 4,
                    accountId: 1,
                    categoryId: 4,
                    amount: 150000,
                    date: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-05-31T13:55:57.197Z")!,
                    comment: nil,
                    createdAt: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-05-31T13:55:57.197Z")!,
                    updatedAt: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-05-31T13:55:57.197Z")!
                   )
    ]
    
    func transactions() async throws -> [Transaction] {
        transactions
    }
    
    func transactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        transactions.filter { $0.date >= startDate && $0.date <= endDate }
    }
    
    func addTransaction(accountId: Int = 0, categoryId: Int, amount: Decimal, date: Date, comment: String? = nil) async throws {
        let newTransaction = Transaction(
            id: (transactions.max(by: { $0.id < $1.id })?.id ?? 0) + 1,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            date: date,
            comment: comment,
            createdAt: Date(),
            updatedAt: Date()
        )
        transactions.append(newTransaction)
    }
    
    func updateTransaction(to updatedTransaction: Transaction) async throws {
        if let idx = transactions.firstIndex(where: { $0.id == updatedTransaction.id }) {
            transactions[idx] = updatedTransaction
        }
    }
    
    func deleteTransaction(_ id: Int) async throws {
        transactions.removeAll { $0.id == id }
    }
}
