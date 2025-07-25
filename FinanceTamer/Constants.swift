//
//  Constants.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 17.07.2025.
//

import Foundation

enum Constants {
    static let baseURLString = "https://shmr-finance.ru/api/v1"
    static let accountsRoute = "/accounts"
    static let categoriesRoute = "/categories"
    static let transactionsRoute = "/transactions"
    
    static func categoriesByTypeRoute(_ type: String) -> String {
        "/categories/type/\(type)"
    }
    static func transactionsByPeriodRoute(accountId: Int) -> String {
        "/transactions/account/\(accountId)/period"
    }
    static func accountHistoryRoute(accountId: Int) -> String {
        "/accounts/\(accountId)/history"
    }
}
