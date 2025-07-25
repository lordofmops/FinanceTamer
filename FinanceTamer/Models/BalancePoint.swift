//
//  BalancePoint.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 25.07.2025.
//

import Foundation

struct BalancePoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let balance: Decimal
    let isPositive: Bool
}
