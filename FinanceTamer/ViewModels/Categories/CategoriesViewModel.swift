//
//  CategoriesViewModel.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 01.07.2025.
//
import Foundation

final class CategoriesViewModel: ObservableObject {
    @Published var categories: [Category] = []
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
            let categories = try await categoriesService.categories()
            
            await MainActor.run {
                self.categories = categories
            }
        } catch {
            print("Error loading categories: \(error)")
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

