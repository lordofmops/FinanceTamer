//
//  PieChartCell.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 25.07.2025.
//

import UIKit
import PieChart

final class PieChartCell: UITableViewCell {
    static let identifier = "pieChartCell"

    private let chartView = PieChartView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        self.backgroundColor = .background
        
        chartView.backgroundColor = .background
        chartView.innerBackgroundColor = .background
        chartView.segmentColors = [
            .ftPink, .ftYellow, .ftBlue, .ftOrange, .ftPurple, .ftCoral
        ]
        contentView.addSubview(chartView)
        chartView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            chartView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            chartView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chartView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    func configure(with transactions: [ExtendedTransaction]) {
        let grouped = transactions.reduce(into: [String: Decimal]()) { result, transaction in
            result[transaction.category.name, default: 0] += transaction.transaction.amount
        }

        let sorted = grouped.sorted { $0.value > $1.value }

        let top5 = sorted.prefix(5)
        let rest = sorted.dropFirst(5)
        var entities: [Entity] = top5.map { Entity(value: $0.value, label: $0.key) }

        if !rest.isEmpty {
            let restSum = rest.map { $0.value }.reduce(0, +)
            entities.append(Entity(value: restSum, label: "Остальные"))
        }

        chartView.animateToNewData(entities)
    }
}
