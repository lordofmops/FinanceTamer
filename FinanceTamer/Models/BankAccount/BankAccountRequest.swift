//
//  BankAccountRequest.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 17.07.2025.
//

import Foundation

struct BankAccountRequest: Encodable {
    let name: String
    let balance: Decimal
    let currency: String
}
