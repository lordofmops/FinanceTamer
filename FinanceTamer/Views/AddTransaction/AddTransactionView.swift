//
//  AddTransactionView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 12.07.2025.
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: AddTransactionViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: AddTransactionViewModel())
    }
    
    private var categoryRow: some View {
        VStack {
            Button {
                withAnimation {
                    viewModel.showCategoryPicker.toggle()
                }
            } label: {
                HStack {
                    Text("Статья")
                        .foregroundColor(.header)
                    Spacer()
                    Text(viewModel.selectedCategory?.name ?? "")
                        .foregroundColor(.gray)
                }
            }
            
            if viewModel.showCategoryPicker {
                Picker("Категория", selection: $viewModel.selectedCategory) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        Text(category.name)
                            .tag(category as Category?)
                    }
                }
                .pickerStyle(.wheel)
            }
        }
    }
    
    private var sumRow: some View {
        HStack {
            Text("Сумма")
            Spacer()
            TextField("0", text: $viewModel.amountString)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
    }
    
    private var dateRow: some View {
        HStack {
            Text("Дата")
            Spacer()
            DatePicker("",
                       selection: $viewModel.date,
                       in: ...viewModel.maximumDate,
                       displayedComponents: .date)
                .labelsHidden()
        }
    }
    
    private var timeRow: some View {
        HStack {
            Text("Время")
            Spacer()
            DatePicker("", selection: $viewModel.time, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
    }
    
    private var commentRow: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $viewModel.comment)
                .frame(height: 44)
            
            if viewModel.comment.isEmpty {
                Text("Комментарий")
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .padding(.leading, 5)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Form {
                    Section {
                        categoryRow
                        sumRow
                        dateRow
                        timeRow
                        commentRow
                    }
                }
                .listSectionSpacing(40)
                .navigationTitle("Добавить операцию")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Отмена") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Создать") {
                            Task {
                                let success = await viewModel.addTransaction()
                                if success {
                                    dismiss()
                                }
                            }
                        }
                    }
                }
            }
            .alert("Что-то не так", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) {
                    viewModel.showErrorAlert = false
                }
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
            
        }
    }
}

#Preview {
    TransactionsListView(direction: .outcome)
}
