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
    
    let extendedTransaction: ExtendedTransaction
    
    var amount: Decimal {
        Decimal(string: amountString.filterBalanceString()) ?? 0
    }
    var maximumDate: Date {
        Calendar.current.startOfDay(for: Date())
    }
    
    private let transactionsService = TransactionsService.shared
    private let categoriesService = CategoriesService.shared
    
    init(_ extendedTransaction: ExtendedTransaction) {
        self.extendedTransaction = extendedTransaction
        self.selectedCategory = extendedTransaction.category
        self.amountString = extendedTransaction.transaction.amount.formatted()
        self.date = extendedTransaction.transaction.date
        self.time = extendedTransaction.transaction.date
        self.comment = extendedTransaction.transaction.comment ?? ""
        
        loadCategories()
    }
    
    private func loadCategories() {
        Task { @MainActor in
            do {
                let fetchedCategories = try await categoriesService.categories()
                self.categories = fetchedCategories.filter { $0.direction == extendedTransaction.category.direction }
            } catch {
                print("Error fetching categories: \(error)")
            }
        }
    }
    
    func save() async {
        do {
            let fullDate = merge(date: date, time: time)
            
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
        } catch {
            await MainActor.run {
                print("Error saving transaction: \(error)")
            }
        }
    }
    
    func delete() async {
        do {
            try await transactionsService.deleteTransaction(extendedTransaction.id)
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
