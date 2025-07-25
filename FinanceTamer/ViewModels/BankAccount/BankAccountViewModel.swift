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
            let yearAgo = calendar.date(byAdding: .year, value: -2, to: Date()) ?? Date()
            
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
        switch period {
        case .daily:
            return generateDailyBalancePoints()
        case .monthly:
            return generateMonthlyBalancePoints()
        }
    }
    
    private func filterBalanceString(_ balance: String) -> String {
        return balance.filterBalanceString()
    }
    
    private func generateDailyBalancePoints() -> [BalancePoint] {
        guard !history.isEmpty else {
            return []
        }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var nextIdx = 1
        var points: [BalancePoint] = []
        points.append(
            BalancePoint(
                date: history[0].date,
                balance: history[0].balance,
                isPositive: history[0].balance > 0
            )
        )
        for i in 0..<31 {
            guard nextIdx < history.count else {
                if points.count < 30 {
                    let lastPoint = points[points.count - 1]
                    for i in points.count...30 {
                        points[i] = lastPoint
                    }
                }
                return points
            }
            let date = calendar.date(byAdding: .day, value: i * (-1), to: today)!
            
            if nextIdx < history.count || history[nextIdx].date < date{
                points.append(
                    BalancePoint(
                        date: history[nextIdx - 1].date,
                        balance: history[nextIdx - 1].balance,
                        isPositive: history[nextIdx - 1].balance > 0
                    )
                )
            } else {
                while nextIdx < history.count && history[nextIdx].date >= date {
                    points.append(
                        BalancePoint(
                            date: history[nextIdx].date,
                            balance: history[nextIdx].balance < 0 ? history[nextIdx].balance * (-1) : history[nextIdx].balance,
                            isPositive: history[nextIdx].balance > 0
                        )
                    )
                    nextIdx += 1
                }
            }
            print(date)
            print(points.last!.date, points.last!.balance, "\n")
        }
        
        return points.reversed()
    }
    
    private func generateMonthlyBalancePoints() -> [BalancePoint] {
        guard !history.isEmpty else { return [] }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let twoYearsAgo = calendar.date(byAdding: .year, value: -2, to: today)!

        var points: [BalancePoint] = []

        var currentIdx = 0
        var currentBalance = history.first!.balance

        for monthOffset in 0..<24 {
            guard let date = calendar.date(byAdding: .month, value: monthOffset, to: twoYearsAgo) else { continue }
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
            
            while currentIdx < history.count && history[currentIdx].date < startOfMonth {
                currentBalance = history[currentIdx].balance
                currentIdx += 1
            }
            
            let point = BalancePoint(
                date: startOfMonth,
                balance: currentBalance < 0 ? currentBalance * (-1) : currentBalance,
                isPositive: currentBalance > 0
            )
            
            points.append(point)
            
            print(date)
            print(point.date, point.balance, "\n")
        }

        return points.reversed()
    }
}
