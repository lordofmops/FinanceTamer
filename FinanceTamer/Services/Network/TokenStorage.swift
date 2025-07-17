//
//  TokenStorage.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 16.07.2025.
//

import Foundation

final class TokenStorage {
    static let shared = TokenStorage()
    
    private init() {}

    var token: String? {
        guard let path = Bundle.main.path(forResource: "Token", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let token = dict["Token"] as? String else {
            return nil
        }
        return token
    }
}
