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
    let availableCurrencies = Currency.allCases
    
    private let bankAccountsService = BankAccountsService()
    
    init() {}

    func load() async {
        do {
            let account = try await bankAccountsService.account()
            
            let currency = Currency(rawValue: account.currency) ?? .ruble
            
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
    
    private func filterBalanceString(_ balance: String) -> String {
        var filtered = balance.replacingOccurrences(of: ",", with: ".")
        
        let isNegative = filtered.hasPrefix("-")
        
        filtered = filtered.filter { "0123456789.".contains($0) }
        
        let dotCount = filtered.filter { $0 == "." }.count
        if dotCount > 1 {
            if let firstDotIndex = filtered.firstIndex(of: ".") {
                let beforeDot = filtered[..<firstDotIndex]
                let afterDot = filtered[filtered.index(after: firstDotIndex)...].filter { $0 != "." }
                filtered = String(beforeDot) + "." + afterDot
            }
        } else if dotCount == 1 {
            let parts = filtered.components(separatedBy: ".")
            if parts.count == 2 {
                let integerPart = parts[0]
                var fractionalPart = String(parts[1].prefix(3))
                while fractionalPart.hasSuffix("0") {
                    fractionalPart.removeLast()
                }
                if !fractionalPart.isEmpty {
                    filtered = "\(integerPart).\(fractionalPart)"
                } else {
                    filtered = integerPart
                }
            }
        }
        
        if filtered.hasSuffix(".") {
            filtered.removeLast()
        }
        
        if filtered.count > 1 {
            while filtered.hasPrefix("0") && !filtered.hasPrefix("0.") {
                filtered.removeFirst()
            }
        }
        
        if filtered.hasPrefix(".") {
            filtered.insert("0", at: filtered.startIndex)
        }
        
        if filtered.isEmpty || filtered == "." {
            filtered = "0"
        }
        
        if isNegative && filtered != "0" {
            filtered.insert("-", at: filtered.startIndex)
        }
        
        return filtered
    }
}
