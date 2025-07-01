//
//  CategoriesViewModel.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 01.07.2025.
//
import Foundation

final class CategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var incomeCategories: [Category] = []
    @Published var expenseCategories: [Category] = []
    @Published var searchQuery: String = ""
    
    private let categoriesService = CategoriesService()
    
    var filteredCategories: [Category] {
        guard !searchQuery.isEmpty else {
            return categories
        }
        
        return categories.filter { category in
            category.name.fuzzyMatch(searchQuery)
        }
    }
    
    func load() async {
        do {
            async let expenseCategories = categoriesService.categories(direction: .outcome)
            async let incomeCategories = categoriesService.categories(direction: .income)
            
            let (allExpenseCategories, allIncomeCategories) = try await (expenseCategories, incomeCategories)
            
            await MainActor.run {
                self.categories = allIncomeCategories + allExpenseCategories
                self.incomeCategories = allIncomeCategories
                self.expenseCategories = allExpenseCategories
            }
        } catch {
            print("Error loading categories: \(error)")
        }
    }
    
    func filteredCategories(direction: Direction) -> [Category] {
        guard !searchQuery.isEmpty else {
            switch direction {
            case .income:
                return incomeCategories
            case .outcome:
                return expenseCategories
            }
        }
        
        switch direction {
        case .income:
            return incomeCategories.filter { category in
                category.name.fuzzyMatch(searchQuery)
            }
        case .outcome:
            return expenseCategories.filter { category in
                category.name.fuzzyMatch(searchQuery)
            }
        }
    }
}

extension String {
    func fuzzyMatch(_ query: String) -> Bool {
        guard !query.isEmpty else { return true }
        
        var queryIndex = query.startIndex
        for char in self.lowercased() {
            if char == Character(query[queryIndex].lowercased()) {
                queryIndex = query.index(after: queryIndex)
                if queryIndex == query.endIndex {
                    return true
                }
            }
        }
        return false
    }
}

