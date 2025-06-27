//
//  CurrencyPickerView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 27.06.2025.
//

import SwiftUI

struct CurrencyPickerView: View {
    @Binding var selectedCurrency: Currency
    let currencies: [Currency]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Валюта")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 44)

            Divider()

            ForEach(currencies) { currency in
                Button(action: {
                    if currency != selectedCurrency {
                        selectedCurrency = currency
                    }
                    dismiss()
                }) {
                    Text(currency.name)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.lightPurple)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }

                Divider()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    BankAccountView()
}
