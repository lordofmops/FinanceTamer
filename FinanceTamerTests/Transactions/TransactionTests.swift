import XCTest
@testable import FinanceTamer

final class TransactionTests: XCTestCase {
    func testTransactionJSONParsing() {
        let json: [String: Any] = [
            "id": 1,
            "accountId": 1,
            "categoryId": 4,
            "amount": "100.50",
            "transactionDate": "2025-06-12T13:55:57.197Z",
            "comment": "Зарплата",
            "createdAt": "2025-06-12T13:55:57.197Z",
            "updatedAt": "2025-06-12T13:55:57.197Z"
        ]

        let transaction = Transaction.parse(jsonObject: json)
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction?.id, 1)
        XCTAssertEqual(transaction?.amount, Decimal(string: "100.50"))
        XCTAssertEqual(transaction?.comment, "Зарплата")
        XCTAssertEqual(transaction?.date, DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-06-12T13:55:57.197Z"))
    }
    
    func testTransactionToJSON() {
        let date = DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-06-12T13:55:57.197Z")!
        let transaction = Transaction(
            id: 1,
            accountId: 1,
            categoryId: 4,
            amount: 100.50,
            date: date,
            comment: "Зарплата",
            createdAt: date,
            updatedAt: date
        )

        guard let json = transaction.jsonObject as? [String: Any] else {
            XCTFail("jsonObject is not a dictionary")
            return
        }

        XCTAssertEqual(json["accountId"] as? Int, 1)
        XCTAssertEqual(json["amount"] as? Decimal, 100.50)
        XCTAssertEqual(json["comment"] as? String, "Зарплата")
        XCTAssertEqual(json["transactionDate"] as? Date, DateFormatters.iso8601WithFractionalSeconds.date(from: "2025-06-12T13:55:57.197Z")!)
    }
}

