//
//  CategoryResponse.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 17.07.2025.
//

struct CategoryResponse: Decodable {
    let id: Int
    let name: String
    let emoji: String
    let isIncome: Bool
}
