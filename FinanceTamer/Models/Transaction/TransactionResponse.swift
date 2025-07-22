//
//  TransactionResponse.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 17.07.2025.
//

import Foundation

struct TransactionResponse: Decodable {
    let id: Int
    let account: BankAccountBrief
    let category: CategoryResponse
    let amount: String
    let transactionDate: String
    let comment: String?
    let createdAt: String
    let updatedAt: String
}
