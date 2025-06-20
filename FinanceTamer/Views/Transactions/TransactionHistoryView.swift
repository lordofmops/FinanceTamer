//
//  TransactionHistoryView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 20.06.2025.
//

import SwiftUI

struct TransactionHistoryView: View {
    @Environment(\.dismiss) var dismiss
    let direction: Direction
    @StateObject private var viewModel: TransactionHistoryViewModel

    init(direction: Direction) {
        self.direction = direction
        _viewModel = StateObject(wrappedValue: TransactionHistoryViewModel(direction: direction))
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Моя история")
                .padding(.horizontal, 16)
                .font(.system(size: 34, weight: .bold))
            
            List {
                Section {
                    HStack {
                        Text("Начало")
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
                        Text("Сумма")
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
                    .foregroundColor(.navigationBar)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    // анализ
                }) {
                    Image(systemName: "document")
                        .foregroundColor(.navigationBar)
                }
            }
        }
    }
}

#Preview {
    TransactionHistoryView(direction: .outcome)
}
