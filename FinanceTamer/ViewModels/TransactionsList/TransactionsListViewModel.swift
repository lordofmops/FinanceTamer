//
//  TransactionsListViewModel.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 20.06.2025.
//

import Foundation

struct ExtendedTransaction: Identifiable {
    var id: Int { transaction.id }
    let transaction: Transaction
    let category: Category
    let currency: Currency
}

final class TransactionsListViewModel: ObservableObject {
    @Published var extendedTransactions: [ExtendedTransaction] = []
    @Published var total: Decimal = 0
    @Published var currency: Currency = .ruble
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false

    private let transactionsService = TransactionsService.shared
    private let categoriesService = CategoriesService.shared
    private let bankAccountService = BankAccountsService.shared
    
    private let direction: Direction
    
    init(direction: Direction) {
        self.direction = direction
    }

    func load() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            showErrorAlert = false
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        do {
            async let transactions = transactionsService.transactions(from: startOfDay, to: endOfDay)
            async let categories = categoriesService.categories(direction: direction)
            async let bankAccount = bankAccountService.account()
            
            let (loadedTransactions, loadedCategories, loadedAccount) = try await (transactions, categories, bankAccount)
            let currency = Currency(rawValue: loadedAccount.currency) ?? .ruble
            
            var extended: [ExtendedTransaction] = []
            loadedTransactions.forEach { transaction in
                if let category = loadedCategories.filter({ $0.id == transaction.categoryId }).first {
                    extended.append(
                        ExtendedTransaction(
                            transaction: transaction,
                            category: category,
                            currency: currency
                        )
                    )
                }
            }
            let sortedTransactions = extended.sorted { $0.transaction.date > $1.transaction.date }
            
            let total: Decimal = extended.map { $0.transaction.amount }.reduce(0, +)
            
            await MainActor.run {
                self.extendedTransactions = sortedTransactions
                self.total = total
                self.currency = currency
                
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.extendedTransactions = []
                self.total = 0
                
                self.isLoading = false
                self.errorMessage = "Перезагрузите страницу или попробуйте позже"
                self.showErrorAlert = true
            }
            print("Error loading transactions: \(error)")
        }
    }
}
