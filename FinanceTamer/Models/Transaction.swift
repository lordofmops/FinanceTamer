import Foundation

struct Transaction {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let date: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date
}

extension Transaction {
    static func parse(jsonObject: Any) -> Transaction? {
        guard let dictionary = jsonObject as? [String: Any],
              let id = dictionary["id"] as? Int,
              let amountString = dictionary["amount"] as? String,
              let amount = Decimal(string: amountString),
              let dateString = dictionary["transactionDate"] as? String,
              let date = DateFormatters.iso8601WithFractionalSeconds.date(from: dateString),
              let comment = dictionary["comment"] as? String,
              let createdAtString = dictionary["createdAt"] as? String,
              let createdAt = DateFormatters.iso8601WithFractionalSeconds.date(from: createdAtString),
              let updatedAtString = dictionary["updatedAt"] as? String,
              let updatedAt = DateFormatters.iso8601WithFractionalSeconds.date(from: updatedAtString)
        else {
            return nil
        }
        
        let accountId: Int? = {
            if let id = dictionary["accountId"] as? Int {
                return id
            } else if let account = dictionary["account"] as? [String: Any],
                      let id = account["id"] as? Int {
                return id
            } else {
                return nil
            }
        }()
        
        let categoryId: Int? = {
            if let id = dictionary["categoryId"] as? Int {
                return id
            } else if let category = dictionary["category"] as? [String: Any],
                      let id = category["id"] as? Int {
                return id
            } else {
                return nil
            }
        }()
        
        guard let accountId, let categoryId else {
            return nil
        }
        
        return Transaction(id: id,
                           accountId: accountId,
                           categoryId: categoryId,
                           amount: amount,
                           date: date,
                           comment: comment,
                           createdAt: createdAt,
                           updatedAt: updatedAt)
    }
    
    var jsonObject: Any {
        var dictionary: [String: Any] = [
            "accountId": accountId,
            "categoryId": categoryId,
            "amount": amount,
            "transactionDate": date
        ]
        
        if let comment {
            dictionary["comment"] = comment
        }
        
        return dictionary
    }
}
