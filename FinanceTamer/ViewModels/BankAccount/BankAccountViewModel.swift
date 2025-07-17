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
            let filtered = filterBalanceString(balanceString)
            if filtered != balanceString {
                balanceString = filtered
            }
        }
    }
    @Published var selectedCurrency: Currency = .ruble
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false
    
    let availableCurrencies = Currency.allCases
    
    private let bankAccountsService = BankAccountsService.shared
    
    init() {}

    func load() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            showErrorAlert = false
        }
        
        do {
            let account = try await bankAccountsService.account()
            
            let currency = Currency(rawValue: account.currency) ?? .ruble
            
            await MainActor.run {
                self.bankAccount = account
                self.balanceString = account.balance.description
                self.selectedCurrency = currency
                
                self.isLoading = false
            }
        } catch {
            self.isLoading = false
            self.errorMessage = "Перезагрузите страницу или попробуйте позже"
            self.showErrorAlert = true
            
            print("Error loading bank account: \(error)")
        }
    }
    
    func saveChanges() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            showErrorAlert = false
        }
        
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
                self.isLoading = false
            }
        } catch {
            self.isLoading = false
            self.errorMessage = "Перезагрузите страницу или попробуйте позже"
            self.showErrorAlert = true
            
            print("Error saving changes: \(error)")
        }
    }
    
    private func filterBalanceString(_ balance: String) -> String {
        return balance.filterBalanceString()
    }
}
