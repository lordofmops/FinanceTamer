//
//  TransactionResponseBrief.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 17.07.2025.
//

struct TransactionResponseBrief: Decodable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
    let createdAt: String
    let updatedAt: String
}
