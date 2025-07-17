import Foundation

final class TransactionsService {
    static let shared = TransactionsService()
    
    private let networkClient = NetworkClient.shared
    
    private init() {}
    
    @Published private(set) var transactions: [Transaction] = []
    
    func transactions() async throws -> [Transaction] {
        transactions
    }
    
    func transactions(from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        guard let url = URL(string: Constants.baseURLString + Constants.transactionsByPeriodRoute(accountId: 89)) else {
            print("Failed to create transactions URL")
            throw NetworkError.invalidURL
        }
        
        let response: [TransactionResponse] = try await networkClient.request(
            url: url,
            method: .get
        )
        var transactions: [Transaction] = []
        
        response.forEach { transactionResponse in
            transactions.append(Transaction(from: transactionResponse))
        }
        
        self.transactions = transactions
        return transactions
    }
    
    func addTransaction(accountId: Int, categoryId: Int, amount: Decimal, date: Date, comment: String? = nil) async throws {
        let newTransaction = TransactionRequest(
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: date.ISO8601Format(),
            comment: comment ?? ""
        )
        
        guard let url = URL(string: Constants.baseURLString + Constants.transactionsRoute) else {
            print("Failed to create transactions URL")
            throw NetworkError.invalidURL
        }
        
        let response: TransactionResponseBrief = try await networkClient.request(
            url: url,
            method: .post,
            requestBody: newTransaction
        )
        
        transactions.append(Transaction(from: response))
    }
    
    func updateTransaction(to updatedTransaction: Transaction) async throws {
        guard let baseUrl = URL(string: Constants.baseURLString + Constants.transactionsRoute) else {
            print("Failed to create transactions URL")
            throw NetworkError.invalidURL
        }
        let url = baseUrl.appendingPathComponent("/\(updatedTransaction.id)")
        
        let requestBody = TransactionRequest(
            accountId: updatedTransaction.accountId,
            categoryId: updatedTransaction.categoryId,
            amount: updatedTransaction.amount,
            transactionDate: updatedTransaction.date.ISO8601Format(),
            comment: updatedTransaction.comment
        )
        
        let response: TransactionResponse = try await networkClient.request(
            url: url,
            method: .put,
            requestBody: requestBody
        )
        let newTransaction = Transaction(from: response)
        
        if let idx = transactions.firstIndex(where: { $0.id == newTransaction.id }) {
            transactions[idx] = newTransaction
        }
    }
    
    func deleteTransaction(_ id: Int) async throws {
        guard let baseUrl = URL(string: Constants.baseURLString + Constants.transactionsRoute) else {
            print("Failed to create transactions URL")
            throw NetworkError.invalidURL
        }
        let url = baseUrl.appendingPathComponent("/\(id)")
        
        let _: TransactionResponse? = try await networkClient.request(
            url: url,
            method: .delete
        )
        
        transactions.removeAll { $0.id == id }
    }
}
