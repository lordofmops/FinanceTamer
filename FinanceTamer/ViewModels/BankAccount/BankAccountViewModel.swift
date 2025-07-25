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
    
    enum Period {
        case daily
        case monthly
    }
    
    let availableCurrencies = Currency.allCases
    
    private let bankAccountsService = BankAccountsService.shared
    private var history: [BankAccountModification] = []
    
    init() {}
    
    func load() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            showErrorAlert = false
        }
        
        do {
            let calendar = Calendar.current
            
            async let loadAccount = bankAccountsService.account()
            async let loadHistory = bankAccountsService.accountModifications()
            
            let (account, history) = try await (loadAccount, loadHistory)
            
            let currency = Currency(rawValue: account.currency) ?? .ruble
            
            await MainActor.run {
                self.bankAccount = account
                self.balanceString = account.balance.description
                self.selectedCurrency = currency
                self.history = history
                
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
    
    func balancePoints(for period: Period) -> [BalancePoint] {
        guard !history.isEmpty else { return [] }
        
        let sortedHistory = history.sorted { $0.date < $1.date }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        switch period {
        case .daily:
            return generateDailyBalancePoints(history: sortedHistory, today: today)
        case .monthly:
            return generateMonthlyBalancePoints(history: sortedHistory, today: today)
        }
    }

    
    private func filterBalanceString(_ balance: String) -> String {
        return balance.filterBalanceString()
    }
    
    private func generateDailyBalancePoints(history: [BankAccountModification], today: Date) -> [BalancePoint] {
        let calendar = Calendar.current
        var points: [BalancePoint] = []
        let daysCount = 31
        
        let currentBalance = bankAccount?.balance ?? 0
        points.append(BalancePoint(
            date: today,
            balance: currentBalance,
            isPositive: currentBalance >= 0
        ))
        
        for dayOffset in 1..<daysCount {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            let balance = history.last { $0.date <= date }?.balance ?? 0
            
            points.append(BalancePoint(
                date: date,
                balance: balance,
                isPositive: balance >= 0
            ))
        }
        
        return points.reversed()
    }
    
    private func generateMonthlyBalancePoints(history: [BankAccountModification], today: Date) -> [BalancePoint] {
        let calendar = Calendar.current
        var points: [BalancePoint] = []
        let monthsCount = 24
        
        let currentBalance = bankAccount?.balance ?? 0
        points.append(BalancePoint(
            date: today,
            balance: currentBalance,
            isPositive: currentBalance >= 0
        ))
        
        for monthOffset in 1..<monthsCount {
            guard let date = calendar.date(byAdding: .month, value: -monthOffset, to: today),
                  let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else { continue }
            
            let balance = history.last { $0.date <= startOfMonth }?.balance ?? 0
            
            points.append(BalancePoint(
                date: startOfMonth,
                balance: balance,
                isPositive: balance >= 0
            ))
        }
        
        return points.reversed()
    }
}
