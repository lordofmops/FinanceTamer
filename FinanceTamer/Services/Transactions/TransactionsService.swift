import Foundation

final class TransactionsService {
    private var transactions: [Transaction] = [
        Transaction(id: 1,
                    accountId: 1,
                    categoryId: 1,
                    amount: -80000,
                    date: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-06-12T13:55:57.197Z")!,
                    comment: "Аренда",
                    createdAt: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-06-12T13:55:57.197Z")!,
                    updatedAt: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-06-12T13:55:57.197Z")!
                   ),
        Transaction(id: 2,
                    accountId: 1,
                    categoryId: 3,
                    amount: -15000,
                    date: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-06-15T13:55:57.197Z")!,
                    comment: nil,
                    createdAt: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-06-15T13:55:57.197Z")!,
                    updatedAt: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-06-15T13:55:57.197Z")!
                   ),
        Transaction(id: 3,
                    accountId: 1,
                    categoryId: 4,
                    amount: 150000,
                    date: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-05-31T13:55:57.197Z")!,
                    comment: nil,
                    createdAt: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-05-31T13:55:57.197Z")!,
                    updatedAt: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-05-31T13:55:57.197Z")!
                   )
    ]
    
    func transactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        transactions.filter { $0.date >= startDate && $0.date <= endDate }
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
