//
//  TransactionsListView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 20.06.2025.
//

import SwiftUI

enum MyRoute: Hashable {
    case transactionHistory(Direction)
}

struct TransactionsListView: View {
    let direction: Direction

    @StateObject private var viewModel: TransactionsListViewModel
    @State private var path = NavigationPath()
    @State private var selectedTransaction: ExtendedTransaction? = nil
    @State private var showAddTransactionView: Bool = false

    init(direction: Direction) {
        self.direction = direction
        _viewModel = StateObject(wrappedValue: TransactionsListViewModel(direction: direction))
    }
    
    private var totalSection: some View {
        Section(header:
            Text(direction == .outcome ? "Расходы сегодня" : "Доходы сегодня")
                .mainHeaderStyle()
                .padding(.bottom, 20)
        ) {
            HStack {
                Text("Всего")
                    .listRowStyle()
                Spacer()
                Text("\(viewModel.total.formatted()) \(viewModel.currency.symbol)")
                    .listRowStyle()
            }
        }
    }
    
    private var transactionsSection: some View {
        Section(header: Text("Операции")) {
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

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack(alignment: .leading) {
                    List {
                        totalSection
                        transactionsSection
                    }
                    .refreshable {
                        await viewModel.load()
                    }
                    .listSectionSpacing(12)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            showAddTransactionView = true
                        }) {
                            Image("add_transaction_button")
                                .padding()
                        }
                        .frame(width: 56, height: 56)
                        .padding()
                    }
                }
                .task {
                    await viewModel.load()
                }
                .background(Color.background)
                .navigationDestination(for: MyRoute.self) { route in
                    switch route {
                    case .transactionHistory(let direction):
                        TransactionHistoryView(direction: direction)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(value: MyRoute.transactionHistory(direction)) {
                            Image("history_button")
                        }
                    }
                }
                .sheet(item: $selectedTransaction) { transaction in
                    EditTransactionView(extendedTransaction: transaction)
                        .onDisappear {
                            Task {
                                await viewModel.load()
                            }
                        }
                }
                .sheet(isPresented: $showAddTransactionView) {
                    AddTransactionView(direction: direction)
                        .onDisappear {
                            Task {
                                await viewModel.load()
                            }
                        }
                }
                .alert("Что-то не так", isPresented: $viewModel.showErrorAlert) {
                    Button("ОК", role: .cancel) {
                        viewModel.showErrorAlert = false
                    }
                } message: {
                    Text(viewModel.errorMessage ?? "Неизвестная ошибка")
                }
                
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .animation(.easeInOut, value: viewModel.isLoading)
        }
    }
}

#Preview {
    TabBarView()
}
