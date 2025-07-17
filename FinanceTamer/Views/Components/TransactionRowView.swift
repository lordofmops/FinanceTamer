//
//  TransactionRowView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 20.06.2025.
//

import SwiftUI

struct TransactionRowView: View {
    let extendedTransaction: ExtendedTransaction
    
    var onTap: ((ExtendedTransaction) -> Void)? = nil
    let categoriesService = CategoriesService()

    var body: some View {
        HStack {
            Text(String(extendedTransaction.category.emoji))
                .emojiStyle()

            VStack(alignment: .leading) {
                Text(extendedTransaction.category.name)
                    .font(.body)
                if let comment = extendedTransaction.transaction.comment, !comment.isEmpty  {
                    Text(comment)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Text("\(extendedTransaction.transaction.amount.formatted()) ₽")
                .listRowStyle()
            
            if let onTap = onTap {
                Button(action: {
                    onTap(extendedTransaction)
                }) {
                    Image("edit_button")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
}

#Preview {
    TransactionHistoryView(direction: .outcome)
}
