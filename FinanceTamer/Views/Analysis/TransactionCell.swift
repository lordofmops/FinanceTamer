//
//  TransactionCell.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 08.07.2025.
//

import UIKit

final class TransactionCell: UITableViewCell {
    static let identifier = "TransactionCell"
    var total: Decimal?
    
    private let categoryLabel = UILabel()
    private let commentLabel = UILabel()
    private let amountLabel = UILabel()
    private var emojiLabel = UILabel()
    private let percentageLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        let leftStack = UIStackView(arrangedSubviews: [categoryLabel, commentLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 2
        
        let rightStack = UIStackView(arrangedSubviews: [percentageLabel, amountLabel])
        rightStack.axis = .vertical
        rightStack.alignment = .trailing
        rightStack.spacing = 2

        categoryLabel.font = .systemFont(ofSize: 17, weight: .regular)
        commentLabel.font = .systemFont(ofSize: 14, weight: .light)
        commentLabel.textColor = .gray
        amountLabel.font = .systemFont(ofSize: 16, weight: .regular)
        percentageLabel.font = .systemFont(ofSize: 16, weight: .regular)

        contentView.addSubview(emojiLabel)
        contentView.addSubview(leftStack)
        contentView.addSubview(rightStack)

        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            leftStack.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 16),
            leftStack.centerYAnchor.constraint(equalTo: emojiLabel.centerYAnchor),
            leftStack.trailingAnchor.constraint(lessThanOrEqualTo: rightStack.leadingAnchor, constant: -8),

            rightStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            rightStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with extendedTransaction: ExtendedTransaction) {
        if let total {
            let percentageDecimal = extendedTransaction.transaction.amount / total * 100
            let percentageInt = NSDecimalNumber(decimal: percentageDecimal).rounding(accordingToBehavior: .none)
            percentageLabel.text = "\(percentageInt)%"
        }
        if let comment = extendedTransaction.transaction.comment, !comment.isEmpty {
            commentLabel.text = extendedTransaction.transaction.comment
        }
        categoryLabel.text = extendedTransaction.category.name
        amountLabel.text = "\(extendedTransaction.transaction.amount.formatted()) \(extendedTransaction.currency.symbol)"
        emojiLabel.text = String(extendedTransaction.category.emoji)
        emojiLabel.backgroundColor = .lightGreen
        emojiLabel.layer.cornerRadius = 16
    }
}

#Preview {
    AnalysisViewController(direction: .outcome)
}
