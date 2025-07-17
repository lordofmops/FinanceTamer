import Foundation

final class TransactionsService {
    static let shared = TransactionsService()
    
    private var transactions: [Transaction] = []
    private let networkClient = NetworkClient.shared
    
    private init() {}
    
//    func transactions() async throws -> [Transaction] {
//        transactions
//    }
    
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
        
        print("Transactions loaded successfully")
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
        
        print("Transaction added successfully")
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
        
        print("Transaction updated successfully")
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
        
        print("Transaction deleted successfully")
    }
}
