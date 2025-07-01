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
                        if viewModel.categories.isEmpty {
                            Text("Нет статей")
                        } else {
                            ForEach(viewModel.filteredCategories(direction: .outcome)) { category in
                                categoryRow(for: category)
                            }
                        }
                    }
                    
                    Section(header: Text("Доходы")) {
                        if viewModel.categories.isEmpty {
                            Text("Нет статей")
                        } else {
                            ForEach(viewModel.filteredCategories(direction: .income)) { category in
                                categoryRow(for: category)
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
    
    private var searchBar: some View {
        HStack {
            TextField("",
                      text: $viewModel.searchQuery,
                      prompt: Text("Search").foregroundColor(.darkGray)
            )
                .padding(8)
                .padding(.horizontal, 25)
                .background(Color.lightGray)
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.darkGray)
                            .frame(minWidth: 25, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if viewModel.searchQuery.isEmpty {
                            Button(action: {
                                // голосовой ввод??
                            }) {
                                Image(systemName: "microphone.fill")
                                    .foregroundColor(.darkGray)
                                    .frame(minWidth: 25, maxWidth: .infinity, alignment: .trailing)
                                    .padding(.trailing, 8)
                            }
                        } else {
                            Button(action: {
                                viewModel.searchQuery = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.darkGray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
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
