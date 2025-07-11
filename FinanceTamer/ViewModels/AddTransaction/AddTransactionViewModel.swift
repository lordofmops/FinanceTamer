//
//  AddTransactionViewModel.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 12.07.2025.
//

import Foundation
import SwiftUI

final class AddTransactionViewModel: ObservableObject {
    @Published var amountString: String = ""
    @Published var date: Date = Date()
    @Published var time: Date = Date()
    @Published var comment: String = ""
    @Published var showCategoryPicker: Bool = false
    @Published var selectedCategory: Category?
    @Published var categories: [Category] = []
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false
    
    var amount: Decimal {
        Decimal(string: amountString.filterBalanceString()) ?? 0
    }
    var maximumDate: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    private let transactionsService = TransactionsService.shared
    private let categoriesService = CategoriesService()
    private let bankAccountService = BankAccountsService()
    
    init() {
        loadCategories()
    }
    
    private func loadCategories() {
        errorMessage = nil
        showErrorAlert = false
        
        Task { @MainActor in
            do {
                let fetchedCategories = try await categoriesService.categories()
                self.categories = fetchedCategories
            } catch {
                print("Error fetching categories: \(error)")
            }
        }
    }
    
    func addTransaction() async -> Bool {
        await MainActor.run {
            showErrorAlert = false
            errorMessage = nil
        }
        
        guard let category = selectedCategory else {
            await MainActor.run {
                showErrorAlert = true
                errorMessage = "Выберите категорию"
            }
            return false
        }
        
        guard amount > 0 else {
            await MainActor.run {
                showErrorAlert = true
                errorMessage = "Введите сумму транзакции"
            }
            return false
        }
        
        do {
            let fullDate = merge(date: date, time: time)
            
            let bankAccount = try await bankAccountService.account()
            
            try await transactionsService.addTransaction(
                accountId: bankAccount.id,
                categoryId: category.id,
                amount: amount,
                date: fullDate,
                comment: comment.isEmpty ? nil : comment
            )
            
            return true
        } catch {
            await MainActor.run {
                errorMessage = "Ошибка при добавлении транзакции :("
                showErrorAlert = true
                print("Error adding transaction: \(error)")
            }
            return false
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
