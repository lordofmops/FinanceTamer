//
//  AddTransactionViewModel.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 12.07.2025.
//

import Foundation
import SwiftUI

final class AddTransactionViewModel: ObservableObject {
    @Published var amountString: String = "0.0"
    @Published var date: Date = Date()
    @Published var time: Date = Date()
    @Published var comment: String = ""
    @Published var showCategoryPicker: Bool = false
    @Published var selectedCategory: Category?
    @Published var categories: [Category] = []
    
    var amount: Decimal {
        Decimal(string: amountString.filter { $0.isNumber || $0 == "." || $0 == "," }) ?? 0
    }
    
    private let transactionsService = TransactionsService.shared
    private let categoriesService = CategoriesService()
    
    init() {
        loadCategories()
    }
    
    private func loadCategories() {
        Task { @MainActor in
            do {
                let fetchedCategories = try await categoriesService.categories()
                self.categories = fetchedCategories
                self.selectedCategory = fetchedCategories.first
            } catch {
                print("Error fetching categories: \(error)")
            }
        }
    }
    
    func addTransaction() async -> Bool {
        guard let category = selectedCategory else {
            return false
        }
        
        guard amount > 0 else {
            return false
        }
        
        do {
            let fullDate = merge(date: date, time: time)
            
            try await transactionsService.addTransaction(
                categoryId: category.id,
                amount: amount,
                date: fullDate,
                comment: comment.isEmpty ? nil : comment
            )
            
            return true
        } catch {
            await MainActor.run {
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
