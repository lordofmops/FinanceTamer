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
                Text("Мои статьи")
                    .padding()
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.header)
                    .textCase(nil)
                
                searchBar
                    .frame(height: 36)
                    .padding(.horizontal, 16)
                    .padding(.vertical, -8)
                
                List {
                    Section(header: Text("Статьи")) {
                        if viewModel.categories.isEmpty {
                            Text("Нет статей")
                        } else {
                            ForEach(viewModel.filteredCategories) { category in
                                categoryRow(for: category)
                            }
                        }
                    }
                }
            }
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
