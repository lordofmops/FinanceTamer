import Foundation

final class TransactionsFileCache {
    private(set) var transactions: [Transaction] = []
    private var transactionsById: [Int: Transaction] = [:]
    
    func add(_ transaction: Transaction) {
        transactionsById[transaction.id] = transaction
        updateTransactionsArray()
    }
    
    func remove(id: Int) {
        transactionsById.removeValue(forKey: id)
        updateTransactionsArray()
    }
    
    func save(to url: URL) throws {
        let transactionsJson = transactions.map({ $0.jsonObject })
        let data = try JSONSerialization.data(withJSONObject: transactionsJson, options: [])
        try data.write(to: url)
    }
    
    func load(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let jsonArray = jsonObject as? [Any] else { return }
        
        var transactionsById: [Int: Transaction] = [:]
        for object in jsonArray {
            if let transaction = Transaction.parse(jsonObject: object) {
                transactionsById[transaction.id] = transaction
            }
        }
        
        self.transactionsById = transactionsById
        updateTransactionsArray()
    }
    
    private func updateTransactionsArray() {
        self.transactions = Array(self.transactionsById.values).sorted(by: { $0.date > $1.date })
    }
}
