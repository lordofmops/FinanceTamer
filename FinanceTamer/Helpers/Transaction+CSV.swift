import Foundation

extension Transaction {
    static func load(fromCSV url: URL) throws -> [Transaction] {
        let data = try Data(contentsOf: url)
        
        guard let content = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "CSVError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid file encoding"])
        }
        
        let lines = content.components(separatedBy: .newlines)
        guard lines.count > 1 else { return [] }

        var transactions: [Transaction] = []
        for line in lines.dropFirst() where !line.trimmingCharacters(in: .whitespaces).isEmpty {
            let components = line.components(separatedBy: ",")
            guard components.count >= 6,
                  let id = Int(components[0]),
                  let accountId = Int(components[1]),
                  let categoryId = Int(components[2]),
                  let amount = Decimal(string: components[3]),
                  let date = DateFormatters.iso8601WithFractionalSeconds.date(from: components[4]) else {
                continue
            }
            let comment = components[5]

            transactions.append(Transaction(
                id: id,
                accountId: accountId,
                categoryId: categoryId,
                amount: amount,
                date: date,
                comment: comment,
                createdAt: date,
                updatedAt: date
            ))
        }

        return transactions
    }
    
    static func save(_ transactions: [Transaction], toCSV url: URL) throws {
        var csvString = "id,accountId,categoryId,amount,transactionDate,comment\n"
        
        for transaction in transactions {
            let line = [
                String(transaction.id),
                String(transaction.accountId),
                String(transaction.categoryId),
                "\(transaction.amount)",
                DateFormatters.iso8601WithFractionalSeconds.string(from: transaction.date),
                transaction.comment?.replacingOccurrences(of: ",", with: " ") ?? ""
            ].joined(separator: ",")
            
            csvString += line + "\n"
        }
        
        guard let data = csvString.data(using: .utf8) else {
            throw NSError(domain: "CSVError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to encode CSV data"])
        }
        
        try data.write(to: url)
    }
}
