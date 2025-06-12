import Foundation

final class BankAccountsService {
    private var account = BankAccount(
        id: 1,
        userId: 1,
        name: "Основной счет",
        balance: 15000.50,
        currency: "RUB",
        createdAt: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-06-12T13:46:27.099Z")!,
        updatedAt: DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-06-12T13:46:27.099Z")!
    )
    
    func account() async throws -> BankAccount {
        account
    }
    
    func updateAccount(to updatedAccount: BankAccount) async throws {
        account = updatedAccount
    }
}
