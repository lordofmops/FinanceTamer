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
    @Published var currency: Currency = .ruble

    private let direction: Direction
    private let category: Category?
    private let transactionsService = TransactionsService.shared
    private let categoriesService = CategoriesService.shared
    private let bankAccountsService = BankAccountsService.shared

    private var cancellables = Set<AnyCancellable>()
    
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

    init(direction: Direction, category: Category? = nil) {
        self.direction = direction
        self.category = category

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
    
    func sortTransactions(by option: SortOption) {
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
            async let account = bankAccountsService.account()
            
            let (loadedTransactions, allCategories, bankAccount) = try await (transactions, categories, account)
            
            let categoriesDict = category == nil
                ? Dictionary(uniqueKeysWithValues: allCategories.map { ($0.id, $0) })
                : [category!.id : category!]
            let currency = Currency(rawValue: bankAccount.currency) ?? .ruble
            
            let extended = loadedTransactions
                .reduce(into: [ExtendedTransaction]()) { result, transaction in
                    guard let category = categoriesDict[transaction.categoryId],
                          category.direction == direction else { return }
                    
                    result.append(ExtendedTransaction(transaction: transaction, category: category, currency: currency))
                }
                .sorted { $0.transaction.createdAt > $1.transaction.createdAt }
            
            
            let total: Decimal = extended.map { $0.transaction.amount }.reduce(0, +)
            
            await MainActor.run {
                self.extendedTransactions = extended
                self.total = total
                self.currency = currency
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
