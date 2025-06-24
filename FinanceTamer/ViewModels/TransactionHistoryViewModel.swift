//
//  TransactionHistoryViewModel.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 20.06.2025.
//

import Foundation
import Combine

final class TransactionHistoryViewModel: ObservableObject {
    @Published var dateFrom: Date
    @Published var dateTo: Date
    @Published var extendedTransactions: [ExtendedTransaction] = []
    @Published var total: Decimal = 0

    private let direction: Direction
    private let transactionsService = TransactionsService()
    private let categoriesService = CategoriesService()

    private var cancellables = Set<AnyCancellable>()

    init(direction: Direction) {
        self.direction = direction

        let calendar = Calendar.current
        self.dateTo = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
        self.dateFrom = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()

        $dateFrom
            .combineLatest($dateTo)
            .sink { [weak self] _, _ in
                Task { [weak self] in
                    await self?.load()
                }
            }
            .store(in: &cancellables)

        Task { [weak self] in
            await self?.load()
        }
    }
    
    func sortTransactions(by option: TransactionHistoryView.SortOption) {
        switch option {
        case .date_desc:
            extendedTransactions.sort { $0.transaction.date > $1.transaction.date }
        case .date_asc:
            extendedTransactions.sort { $0.transaction.date < $1.transaction.date }
        case .amount_desc:
            extendedTransactions.sort { abs($0.transaction.amount) > abs($1.transaction.amount) }
        case .amount_asc:
            extendedTransactions.sort { abs($0.transaction.amount) < abs($1.transaction.amount) }
        }
    }

    func load() async {
        do {
            let calendar = Calendar.current
            let dateFrom = calendar.startOfDay(for: self.dateFrom)
            let dateTo = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: self.dateTo) ?? self.dateTo
            
            async let transactions = transactionsService.transactions(from: dateFrom, to: dateTo)
            async let categories = categoriesService.categories()
            
            let (loadedTransactions, allCategories) = try await (transactions, categories)
            let categoriesDict = Dictionary(uniqueKeysWithValues: allCategories.map { ($0.id, $0) })
            
            let extended = loadedTransactions
                .reduce(into: [ExtendedTransaction]()) { result, transaction in
                    guard let category = categoriesDict[transaction.categoryId],
                          category.direction == direction else { return }
                    
                    result.append(ExtendedTransaction(transaction: transaction, category: category))
                }
                .sorted { $0.transaction.createdAt > $1.transaction.createdAt }
            
            
            let total: Decimal = extended.map { $0.transaction.amount }.reduce(0, +)
            
            await MainActor.run {
                self.extendedTransactions = extended
                self.total = total
                sortTransactions(by: .date_desc)
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
