//
//  EditTransactionView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 11.07.2025.
//

import SwiftUI

struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: EditTransactionViewModel
    
    private let extendedTransaction: ExtendedTransaction
    private let direction: Direction
    
    init(extendedTransaction: ExtendedTransaction) {
        self.extendedTransaction = extendedTransaction
        _viewModel = StateObject(wrappedValue: EditTransactionViewModel(extendedTransaction))
        self.direction = extendedTransaction.category.direction
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
                    Text(viewModel.selectedCategory.name)
                        .foregroundColor(.gray)
                }
            }
            
            if viewModel.showCategoryPicker {
                Picker("Категория", selection: $viewModel.selectedCategory) {
                    ForEach(viewModel.categories, id: \.self) { category in
                        Text(category.name)
                            .tag(category.name)
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
    
    private var deleteButton: some View {
        let text: String
        switch direction {
        case .income:
            text = "Удалить доход"
        case .outcome:
            text = "Удалить расход"
        }
        
        return Button(text) {
            Task {
                await viewModel.delete()
                dismiss()
            }
        }
        .foregroundColor(.red)
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
                    
                    Section {
                        deleteButton
                    }
                }
                .listSectionSpacing(40)
            }
            .navigationTitle(direction == .outcome ? "Мои Расходы" : "Мои Доходы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        Task {
                            await viewModel.save()
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TransactionsListView(direction: .outcome)
}
