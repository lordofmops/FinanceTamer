//
//  EditTransactionViewModel.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 11.07.2025.
//

import Foundation
import SwiftUI

final class EditTransactionViewModel: ObservableObject {
    @Published var amountString: String
    @Published var date: Date
    @Published var time: Date
    @Published var comment: String
    @Published var showCategoryPicker: Bool = false
    @Published var selectedCategory: Category
    @Published var categories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false
    
    let extendedTransaction: ExtendedTransaction
    
    var amount: Decimal {
        Decimal(string: amountString.filterBalanceString()) ?? 0
    }
    var maximumDate: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    private let direction: Direction
    
    private let transactionsService = TransactionsService.shared
    private let categoriesService = CategoriesService.shared
    private let bankAccountService = BankAccountsService.shared
    
    init(_ extendedTransaction: ExtendedTransaction) {
        self.extendedTransaction = extendedTransaction
        self.selectedCategory = extendedTransaction.category
        self.amountString = extendedTransaction.transaction.amount.formatted()
        self.date = extendedTransaction.transaction.date
        self.time = extendedTransaction.transaction.date
        self.comment = extendedTransaction.transaction.comment ?? ""
        
        self.direction = extendedTransaction.category.direction
        
        loadCategories()
    }
    
    private func loadCategories() {
        errorMessage = nil
        showErrorAlert = false
        isLoading = true
        
        Task { @MainActor in
            do {
                self.categories = try await categoriesService.categories(direction: direction)
                self.isLoading = false
            } catch {
                errorMessage = "Не получилось загрузить категории"
                showErrorAlert = true
                isLoading = false
                print("Error fetching categories: \(error)")
            }
        }
    }
    
    func save() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            showErrorAlert = false
        }
        
        do {
            let fullDate = merge(date: date, time: time)
            let bankAccount = try await bankAccountService.account()
            
            let newTransaction = Transaction(
                id: extendedTransaction.id,
                accountId: extendedTransaction.transaction.accountId,
                categoryId: selectedCategory.id,
                amount: amount,
                date: fullDate,
                comment: comment.isEmpty ? nil : comment,
                createdAt: extendedTransaction.transaction.createdAt,
                updatedAt: Date()
            )
            
            try await transactionsService.updateTransaction(to: newTransaction)
            
            var newBalance = bankAccount.balance
            switch direction {
            case .income:
                newBalance += amount
            case .outcome:
                newBalance -= amount
            }
            
            try await bankAccountService.updateAccount(to:
                BankAccount(
                    id: bankAccount.id,
                    userId: bankAccount.userId,
                    name: bankAccount.name,
                    balance: newBalance,
                    currency: bankAccount.currency,
                    createdAt: bankAccount.createdAt,
                    updatedAt: bankAccount.updatedAt
                )
            )
            
            await MainActor.run {
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Перезагрузите страницу или попробуйте позже"
                self.showErrorAlert = true
                
                print("Error saving transaction: \(error)")
            }
        }
    }
    
    func delete() async {
        do {
            let bankAccount = try await bankAccountService.account()
            
            try await transactionsService.deleteTransaction(extendedTransaction.id)
            
            var newBalance = bankAccount.balance
            switch direction {
            case .income:
                newBalance -= extendedTransaction.transaction.amount
            case .outcome:
                newBalance += extendedTransaction.transaction.amount
            }
            
            try await bankAccountService.updateAccount(to:
                BankAccount(
                    id: bankAccount.id,
                    userId: bankAccount.userId,
                    name: bankAccount.name,
                    balance: newBalance,
                    currency: bankAccount.currency,
                    createdAt: bankAccount.createdAt,
                    updatedAt: bankAccount.updatedAt
                )
            )
        } catch {
            await MainActor.run {
                print("Error deleting transaction: \(error)")
            }
        }
    }
    
    private func merge(date: Date, time: Date) -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        var mergedComponents = DateComponents()
        mergedComponents.year = dateComponents.year
        mergedComponents.month = dateComponents.month
        mergedComponents.day = dateComponents.day
        mergedComponents.hour = timeComponents.hour
        mergedComponents.minute = timeComponents.minute
        mergedComponents.second = timeComponents.second
        
        return calendar.date(from: mergedComponents) ?? date
    }
}
