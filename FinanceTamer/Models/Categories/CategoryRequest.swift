//
//  CategoryRequest.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 17.07.2025.
//

struct CategoryRequest: Encodable {
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool
}
