//
//  CategoriesView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 20.06.2025.
//

import SwiftUI

struct CategoriesListView: View {
    @StateObject private var viewModel = CategoriesViewModel()
    
    init() {
        _viewModel = StateObject(wrappedValue: CategoriesViewModel())
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                List {
                    Section(header: Text("Расходы")) {
                        if viewModel.expenseCategories.isEmpty {
                            Text("Нет статей")
                        } else {
                            ForEach(viewModel.filteredCategories(direction: .outcome)) { category in
                                NavigationLink {
                                    TransactionHistoryView(direction: category.direction, category: category)
                                } label: {
                                    categoryRow(for: category)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Доходы")) {
                        if viewModel.incomeCategories.isEmpty {
                            Text("Нет статей")
                        } else {
                            ForEach(viewModel.filteredCategories(direction: .income)) { category in
                                NavigationLink {
                                    TransactionHistoryView(direction: category.direction, category: category)
                                } label: {
                                    categoryRow(for: category)
                                }
                            }
                        }
                    }
                }
                .searchable(text: $viewModel.searchQuery)
            }
            .navigationTitle("Мои статьи")
            .background(Color.background)
            .task {
                await viewModel.load()
            }
        }
    }
    
    private func categoryRow(for category: Category) -> some View {
         HStack {
            Text(String(category.emoji))
                .font(.system(size: 14.5))
                .frame(width: 22, height: 22)
                .background(Color.lightGreen)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(category.name)
                    .font(.body)
            }
        }
    }
}

#Preview {
    CategoriesListView()
}
