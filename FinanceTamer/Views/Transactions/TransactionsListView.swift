//
//  TransactionsListView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 20.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    let direction: Direction

    @StateObject private var viewModel: TransactionsListViewModel

    init(direction: Direction) {
        self.direction = direction
        _viewModel = StateObject(wrappedValue: TransactionsListViewModel(direction: direction))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()
                Button(action: {
                    // история
                }) {
                    Image("history_button")
                }
                .padding(.horizontal, 16)
            }
            Text(direction == .outcome ? "Расходы сегодня" : "Доходы сегодня")
                .padding(.horizontal, 16)
                .font(.system(size: 34, weight: .bold))
        
            List {
                Section {
                    HStack {
                        Text("Всего")
                            .font(.system(size: 17, weight: .regular))
                        Spacer()
                        Text("\(viewModel.total.formatted()) ₽")
                            .font(.system(size: 17, weight: .regular))
                    }
                }
                Section(header: Text("Операции")) {
                    if viewModel.extendedTransactions.isEmpty {
                        Text("Нет операций")
                            .font(.headline)
                    } else {
                        ForEach(viewModel.extendedTransactions) { transaction in
                            TransactionRowView(extendedTransaction: transaction)
                        }
                    }
                }
            }
            .refreshable {
                await viewModel.load()
            }
            
            Spacer()

            HStack {
                Spacer()
                Button(action: {
                    // добавить новую операцию
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
    }
}

#Preview {
    TransactionsListView(direction: .outcome)
}
