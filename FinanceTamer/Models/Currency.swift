//
//  Currency.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 27.06.2025.
//

import Foundation

enum Currency: String, CaseIterable, Identifiable {
    case ruble = "RUB"
    case dollar = "USD"
    case euro = "EUR"
    
    var id: UUID { UUID() }
    
    var code: String { rawValue }
    
    var symbol: String {
        switch self {
        case .ruble:
            return "₽"
        case .dollar:
            return "$"
        case .euro:
            return "€"
        }
    }
    
    var name: String {
        switch self {
        case .ruble:
            return "Российский рубль ₽"
        case .dollar:
            return "Американский доллар $"
        case .euro:
            return "Евро €"
        }
    }
}
