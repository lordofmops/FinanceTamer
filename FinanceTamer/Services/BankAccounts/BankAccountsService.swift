import Foundation

final class BankAccountsService {
    static let shared = BankAccountsService()
    
    private var account: BankAccount?
    private let networkClient = NetworkClient.shared
    private let urlString = Constants.baseURLString + Constants.accountsRoute
    
    private init() {}
    
    func account() async throws -> BankAccount {
        if let account {
            return account
        } else {
            do {
                return try await loadAccount()
            }
        }
    }
    
    private func loadAccount() async throws -> BankAccount {
        guard let url = URL(string: Constants.baseURLString + Constants.accountsRoute) else {
            print("Failed to create account URL")
            throw NetworkError.invalidURL
        }
        
        let response: [BankAccountResponse] = try await networkClient.request(
            url: url,
            method: .get
        )
        let account = BankAccount(from: response[0])
        
        print("Account loaded successfully")
        self.account = account
        return account
    }
    
    func updateAccount(to updatedAccount: BankAccount) async throws {
        guard let baseUrl = URL(string: Constants.baseURLString + Constants.accountsRoute) else {
            print("Failed to create account URL")
            throw NetworkError.invalidURL
        }
        let url = baseUrl.appendingPathComponent("/\(updatedAccount.id)")
        
        let requestBody = BankAccountRequest(
            name: updatedAccount.name,
            balance: updatedAccount.balance,
            currency: updatedAccount.currency
        )
        
        let response: BankAccountResponse = try await networkClient.request(
            url: url,
            method: .put,
            requestBody: requestBody
        )
        
        self.account = BankAccount(from: response)
        print("Account updated successfully")
    }
}
