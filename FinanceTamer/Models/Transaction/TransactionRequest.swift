//
//  TransactionRequest.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 17.07.2025.
//

import Foundation

struct TransactionRequest: Encodable {
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: String
    let comment: String?
}
