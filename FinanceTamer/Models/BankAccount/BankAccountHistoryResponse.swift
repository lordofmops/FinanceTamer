//
//  BankAccountHistoryResponse.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 25.07.2025.
//

import Foundation

struct BankAccountHistoryResponse: Decodable {
    let accountId: Int
    let accountName: String
    let currency: String
    let currentBalance: String
    let history: [BalanceChange]
}

struct BalanceChange: Decodable {
    let id: Int
    let changeTimestamp: Date
    let newState: BalanceState

    struct BalanceState: Decodable {
        let balance: String
    }
}
