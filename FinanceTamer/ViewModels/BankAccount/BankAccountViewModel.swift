//
//  BankAccountViewModel.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 24.06.2025.
//

import Foundation
import Combine

final class BankAccountViewModel: ObservableObject {
    @Published var bankAccount: BankAccount?
    @Published var balanceString: String = "" {
        didSet {
            let filtered = balanceString.filter { "0123456789.".contains($0) }
            if filtered != balanceString {
                balanceString = filtered
            }
        }
    }
    @Published var selectedCurrency: Currency = .ruble
    @Published var isBalanceHidden: Bool = false
    let availableCurrencies: [Currency] = [.ruble, .dollar, .euro]
    
    private let bankAccountsService = BankAccountsService()
    
    init() {
        Task { [weak self] in
            await self?.load()
        }
    }

    func load() async {
        do {
            let account = try await bankAccountsService.account()
            
            let currency: Currency
            switch account.currency {
            case "USD":
                currency = .dollar
            case "EUR":
                currency = .euro
            default:
                currency = .ruble
            }
            
            await MainActor.run {
                self.bankAccount = account
                self.balanceString = account.balance.description
                self.selectedCurrency = currency
            }
        } catch {
            print("Error loading bank account: \(error)")
        }
    }
    
    func saveChanges() async {
        guard let bankAccount else {
            print("Error: no bank account")
            return
        }
        guard let balance = Decimal(string: balanceString) else {
            print("Error: incorrect balance")
            return
        }
        
        let updatedAccount = BankAccount(
            id: bankAccount.id,
            userId: bankAccount.userId,
            name: bankAccount.name,
            balance: balance,
            currency: selectedCurrency.code,
            createdAt: bankAccount.createdAt,
            updatedAt: bankAccount.updatedAt
        )
        
        do {
            try await bankAccountsService.updateAccount(to: updatedAccount)
            
            await MainActor.run {
                self.bankAccount = updatedAccount
            }
        } catch {
            print("Error saving changes: \(error)")
        }
    }
    
    func toggleBalanceVisibility() {
        isBalanceHidden.toggle()
    }
}
