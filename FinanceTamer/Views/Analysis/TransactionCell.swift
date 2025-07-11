//
//  TransactionCell.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 08.07.2025.
//

import UIKit

final class TransactionCell: UITableViewCell {
    static let identifier = "TransactionCell"
    
    private let categoryLabel = UILabel()
    private let commentLabel = UILabel()
    private let amountLabel = UILabel()
    private var emojiLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        let stack = UIStackView(arrangedSubviews: [categoryLabel, commentLabel])
        stack.axis = .vertical
        stack.spacing = 2

        categoryLabel.font = .systemFont(ofSize: 16, weight: .medium)
        commentLabel.font = .systemFont(ofSize: 14, weight: .light)
        commentLabel.textColor = .gray

        contentView.addSubview(emojiLabel)
        contentView.addSubview(stack)
        contentView.addSubview(amountLabel)

        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            stack.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 16),
            stack.centerYAnchor.constraint(equalTo: emojiLabel.centerYAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: amountLabel.leadingAnchor, constant: -8),

            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with extendedTransaction: ExtendedTransaction) {
        commentLabel.text = extendedTransaction.transaction.comment
        categoryLabel.text = extendedTransaction.category.name
        amountLabel.text = "\(extendedTransaction.transaction.amount) ₽"
        emojiLabel.text = String(extendedTransaction.category.emoji)
        emojiLabel.backgroundColor = .lightGreen
        emojiLabel.layer.cornerRadius = 16
    }
}

