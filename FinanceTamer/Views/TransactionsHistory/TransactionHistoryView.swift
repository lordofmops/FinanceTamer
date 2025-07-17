//
//  TransactionHistoryView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 20.06.2025.
//

import SwiftUI

struct TransactionHistoryView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel: TransactionHistoryViewModel
    @State private var sortOption: TransactionHistoryViewModel.SortOption = .date_desc
    @State private var showAnalysis = false
    @State private var selectedTransaction: ExtendedTransaction? = nil
    
    let direction: Direction
    let category: Category?

    init(direction: Direction, category: Category? = nil) {
        self.direction = direction
        self.category = category
        _viewModel = StateObject(wrappedValue: TransactionHistoryViewModel(direction: direction, category: category)
        )
    }

    var body: some View {
        VStack(alignment: .leading) {
            List {
                Section(header:
                    Text("Моя история")
                        .mainHeaderStyle()
                ) {
                    HStack {
                        Text("Начало")
                            .listRowStyle()
                        Spacer()
                        CustomDatePicker(date: $viewModel.dateFrom)
                    }
                    .onChange(of: viewModel.dateFrom) { oldValue, newValue in
                        if newValue > viewModel.dateTo {
                            viewModel.dateTo = newValue
                        }
                        if oldValue != newValue {
                            Task {
                                await viewModel.load()
                            }
                        }
                    }
                    
                    HStack {
                        Text("Конец")
                            .listRowStyle()
                        Spacer()
                        CustomDatePicker(date: $viewModel.dateTo)
                    }
                    .onChange(of: viewModel.dateTo) { oldValue, newValue in
                        if newValue < viewModel.dateFrom {
                            viewModel.dateFrom = newValue
                        }
                        if oldValue != newValue {
                            Task {
                                await viewModel.load()
                            }
                        }
                    }
                    
                    HStack {
                        Text("Сортировка")
                            .listRowStyle()
                        Spacer()
                        Menu {
                            Text("Показывать сначала")
                            
                            Picker(selection: $sortOption, label: EmptyView()) {
                                ForEach(TransactionHistoryViewModel.SortOption.allCases, id: \.self) { option in
                                    Label(option.rawValue, systemImage: option.icon).tag(option)
                                }
                            }
                        } label: {
                            HStack {
                                Text(sortOption.rawValue)
                                    .listRowStyle(.black)
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }
                            .frame(height: 34)
                            .padding(.horizontal, 12)
                            .background(Color.lightGreen)
                            .cornerRadius(6)
                        }
                        .onChange(of: sortOption) { _, newOption in
                            viewModel.sortTransactions(by: newOption)
                        }
                    }
                    
                    HStack {
                        Text("Сумма")
                            .listRowStyle()
                        Spacer()
                        Text("\(viewModel.total.formatted()) \(viewModel.currency.symbol)")
                            .listRowStyle()
                    }
                    
                }
                
                Section(header:
                    Text("Операции")
                        .padding(.horizontal, -18)
                ) {
                    if viewModel.extendedTransactions.isEmpty {
                        Text("Нет операций")
                            .font(.headline)
                    } else {
                        ForEach(viewModel.extendedTransactions) { transaction in
                            TransactionRowView(extendedTransaction: transaction) {_ in
                                selectedTransaction = transaction
                            }
                        }
                    }
                }
            }
            .padding(.top, -20)
            .listSectionSpacing(0)
            .refreshable {
                Task {
                    await viewModel.load()
                }
            }
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Назад")
                    }
                    .foregroundColor(.lightPurple)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showAnalysis = true
                }) {
                    Image(systemName: "document")
                        .foregroundColor(.lightPurple)
                }
            }
        }.fullScreenCover(isPresented: $showAnalysis) {
            AnalysisView(direction: direction)
                .ignoresSafeArea()
        }
        .sheet(item: $selectedTransaction) { transaction in
            EditTransactionView(extendedTransaction: transaction)
                .onDisappear() {
                    Task {
                        await viewModel.load()
                    }
                }
        }
    }
}

#Preview {
    TransactionHistoryView(direction: .outcome)
//    TabBarView()
}
