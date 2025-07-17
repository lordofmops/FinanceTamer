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

    private let transactionsService = TransactionsService.shared
    private let categoriesService = CategoriesService.shared
    private let bankAccountService = BankAccountsService.shared
    
    private let direction: Direction
    
    init(direction: Direction) {
        self.direction = direction
    }

    func load() async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        do {
            async let transactions = transactionsService.transactions(from: startOfDay, to: endOfDay)
            async let categories = categoriesService.categories()
            async let bankAccount = bankAccountService.account()
            
            let (loadedTransactions, allCategories, account) = try await (transactions, categories, bankAccount)
            let categoriesDict = Dictionary(uniqueKeysWithValues: allCategories.map { ($0.id, $0) })
            let currency = Currency(rawValue: account.currency) ?? .ruble
            
            let extended = loadedTransactions
                .reduce(into: [ExtendedTransaction]()) { result, transaction in
                    guard let category = categoriesDict[transaction.categoryId],
                          category.direction == direction else { return }
                    
                    result.append(ExtendedTransaction(transaction: transaction, category: category, currency: currency))
                }
                .sorted { $0.transaction.date > $1.transaction.date }
            
            
            let total: Decimal = extended.map { $0.transaction.amount }.reduce(0, +)
            
            await MainActor.run {
                self.extendedTransactions = extended
                self.total = total
                self.currency = currency
            }
            
        } catch {
            await MainActor.run {
                self.extendedTransactions = []
                self.total = 0
            }
            print("Error loading transactions: \(error)")
        }
    }
}
