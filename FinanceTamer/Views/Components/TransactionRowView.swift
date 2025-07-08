//
//  TransactionRowView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 20.06.2025.
//

import SwiftUI

struct TransactionRowView: View {
    let extendedTransaction: ExtendedTransaction
    
    let categoriesService = CategoriesService()

    var body: some View {
        HStack {
            Text(String(extendedTransaction.category.emoji))
                .emojiStyle()

            VStack(alignment: .leading) {
                Text(extendedTransaction.category.name)
                    .font(.body)
                if let comment = extendedTransaction.transaction.comment {
                    Text(comment)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Text("\(extendedTransaction.transaction.amount.formatted()) ₽")
                .listRowStyle()
            
            Button(action: {
                // изменить операцию
            }) {
                Image("edit_button")
            }
            .frame(width: 16, height: 36)
        }
    }
}

#Preview {
    TransactionHistoryView(direction: .outcome)
}
