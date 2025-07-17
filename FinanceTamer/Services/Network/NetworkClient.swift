//
//  NetworkClient.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 16.07.2025.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case missingToken
    case requestFailed(statusCode: Int, data: Data)
    case decodingFailed
    case encodingFailed
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .missingToken:
            return "Token is missing"
        case .requestFailed(let statusCode, _):
            return "Invalid request: HTTP \(statusCode)"
        case .decodingFailed:
            return "Decoding failed"
        case .encodingFailed:
            return "Encoding failed"
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

final class NetworkClient {
    static let shared = NetworkClient()

    private let session = URLSession(configuration: .default)

    private init() {}
    
    func request<T: Decodable, U: Encodable>(
        url: URL,
        method: HTTPMethod,
        requestBody: U? = Optional<DefaultEncodable>.none
    ) async throws -> T {
        guard let token = TokenStorage.shared.token else {
            throw NetworkError.missingToken
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = requestBody {
            do {
                let jsonEncoder = JSONEncoder()
                jsonEncoder.dateEncodingStrategy = .iso8601
                request.httpBody = try await JSONEncoder().encodeAsync(body)
            } catch {
                throw NetworkError.encodingFailed
            }
        }

        do {
            let (data, response) = try await session.data(for: request)
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("JSON Response:\n\(jsonString)")
//            }

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.requestFailed(statusCode: -1, data: data)
            }

            guard 200..<300 ~= httpResponse.statusCode else {
                throw NetworkError.requestFailed(statusCode: httpResponse.statusCode, data: data)
            }
            
            if data.isEmpty {
                if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                } else {
                    throw NetworkError.decodingFailed
                }
            }

            do {
                let jsonDecoder = JSONDecoder()
                
                jsonDecoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateStr = try container.decode(String.self)
                    let formatter = DateFormatters.iso8601WithFractionalSeconds
                    
                    if let date = formatter.date(from: dateStr) {
                        return date
                    }
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateStr)")
                }
                
                return try await jsonDecoder.decodeAsync(T.self, from: data)
            } catch {
                throw NetworkError.decodingFailed
            }
        } catch {
            throw NetworkError.network(error)
        }
    }
}
