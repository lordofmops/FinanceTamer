import Foundation

final class BankAccountsService {
    private var account: BankAccount?
    
    private let networkClient = NetworkClient.shared
    private let urlString = Constants.baseURLString + Constants.accountsRoute
    
    func account() async throws -> BankAccount {
        guard let url = URL(string: Constants.baseURLString + Constants.accountsRoute) else {
            print("Failed to create account URL")
            throw NetworkError.invalidURL
        }
        
        let response: [BankAccountResponse] = try await networkClient.request(url: url, method: .get, requestBody: Optional<BankAccountRequest>.none)
        let account = BankAccount(from: response[0])
        
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
    }
}
