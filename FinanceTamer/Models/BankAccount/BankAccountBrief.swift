//
//  BankAccountBrief.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 17.07.2025.
//

import Foundation

struct BankAccountBrief: Decodable {
    let id: Int
    let name: String
    let balance: String
    let currency: String
}
