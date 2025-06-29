//
//  Currency.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 27.06.2025.
//

import Foundation

struct Currency: Identifiable, Equatable {
    let id = UUID()
    let code: String
    let symbol: String
    let name: String
    
    static let ruble = Currency(code: "RUB", symbol: "₽", name: "Российский рубль ₽")
    static let dollar = Currency(code: "USD", symbol: "$", name: "Американский доллар $")
    static let euro = Currency(code: "EUR", symbol: "€", name: "Евро €")
}
