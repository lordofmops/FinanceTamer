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
    @State private var sortOption: SortOption = .date_desc
    let direction: Direction

    init(direction: Direction) {
        self.direction = direction
        _viewModel = StateObject(wrappedValue: TransactionHistoryViewModel(direction: direction)
        )
    }
    
    enum SortOption: String, CaseIterable {
        case date_desc = "Новые"
        case date_asc = "Старые"
        case amount_desc = "Дороже"
        case amount_asc = "Дешевле"
        
        var icon: String {
            switch self {
            case .date_desc: return "calendar.circle"
            case .date_asc: return "calendar.circle.fill"
            case .amount_desc: return "rublesign.circle"
            case .amount_asc: return "rublesign.circle.fill"
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            List {
                Section(header:
                    Text("Моя история")
                        .padding(.horizontal, -18)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black)
                        .textCase(nil)
                ) {
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
                        Text("Сортировка")
                        Spacer()
                        Menu {
                            Text("Показывать сначала")
                            
                            Picker(selection: $sortOption, label: EmptyView()) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Label(option.rawValue, systemImage: option.icon).tag(option)
                                }
                            }
                        } label: {
                            HStack {
                                Text(sortOption.rawValue)
                                    .foregroundColor(.black)
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                            }
                            .frame(height: 34)
                            .padding(.horizontal, 12)
                            .background(.datePicker)
                            .cornerRadius(6)
                        }
                        .onChange(of: sortOption) { _, newOption in
                            viewModel.sortTransactions(by: newOption)
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
                
                Section(header:
                    Text("Операции")
                        .padding(.horizontal, -18)
                ) {
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
//    TabBarView()
}
