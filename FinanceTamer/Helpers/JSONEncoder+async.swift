//
//  JSONEncoder+async.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 16.07.2025.
//

import Foundation

extension JSONEncoder {
    func encodeAsync<T: Encodable>(_ value: T) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let data = try self.encode(value)
                    continuation.resume(returning: data)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
