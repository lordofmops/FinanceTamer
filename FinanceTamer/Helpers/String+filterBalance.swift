//
//  String+filterBalance.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 12.07.2025.
//

extension String {
    func filterBalanceString() -> String {
        var filtered = self.replacingOccurrences(of: ",", with: ".")
        
        let isNegative = filtered.hasPrefix("-")
        
        filtered = filtered.filter { "0123456789.".contains($0) }
        
        let dotCount = filtered.filter { $0 == "." }.count
        if dotCount > 1 {
            if let firstDotIndex = filtered.firstIndex(of: ".") {
                let beforeDot = filtered[..<firstDotIndex]
                let afterDot = filtered[filtered.index(after: firstDotIndex)...].filter { $0 != "." }
                filtered = String(beforeDot) + "." + afterDot
            }
        } else if dotCount == 1 {
            let parts = filtered.components(separatedBy: ".")
            if parts.count == 2 {
                let integerPart = parts[0]
                var fractionalPart = String(parts[1].prefix(3))
                while fractionalPart.hasSuffix("0") {
                    fractionalPart.removeLast()
                }
                if !fractionalPart.isEmpty {
                    filtered = "\(integerPart).\(fractionalPart)"
                } else {
                    filtered = integerPart
                }
            }
        }
        
        if filtered.hasSuffix(".") {
            filtered.removeLast()
        }
        
        if filtered.count > 1 {
            while filtered.hasPrefix("0") && !filtered.hasPrefix("0.") {
                filtered.removeFirst()
            }
        }
        
        if filtered.hasPrefix(".") {
            filtered.insert("0", at: filtered.startIndex)
        }
        
        if filtered.isEmpty || filtered == "." {
            filtered = "0"
        }
        
        if isNegative && filtered != "0" {
            filtered.insert("-", at: filtered.startIndex)
        }
        
        return filtered
    }
}
