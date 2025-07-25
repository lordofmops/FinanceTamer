import Foundation

final class BankAccountsService {
    static let shared = BankAccountsService()
    
    private var account: BankAccount?
    private var accountModifications: [BankAccountModification]?
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
    
    func accountModifications() async throws -> [BankAccountModification] {
        if let accountModifications {
            return accountModifications
        } else {
            do {
                return try await loadHistory()
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
    
    private func loadHistory() async throws -> [BankAccountModification] {
        guard let url = URL(string: Constants.baseURLString + Constants.accountHistoryRoute(accountId: account?.id ?? 89)) else {
            print("Failed to create account history URL")
            throw NetworkError.invalidURL
        }
        
        let response: BankAccountHistoryResponse = try await networkClient.request(
            url: url,
            method: .get
        )
        
        let history = response.history
        
        var modifications: [BankAccountModification] = []
        for modification in history {
            modifications.append(
                BankAccountModification(
                    id: modification.id,
                    balance: Decimal(string: modification.newState.balance) ?? 0,
                    date: modification.changeTimestamp
                )
            )
        }
        
        print("Account history loaded successfully")
        return modifications.sorted(by: { $0.date < $1.date })
    }
}
