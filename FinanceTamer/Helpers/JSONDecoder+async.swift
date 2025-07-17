//
//  JSONDecoder+async.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 16.07.2025.
//

import Foundation

extension JSONDecoder {
    func decodeAsync<T: Decodable>(_ type: T.Type, from data: Data) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let object = try self.decode(T.self, from: data)
                    continuation.resume(returning: object)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
