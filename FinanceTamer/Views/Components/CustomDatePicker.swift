//
//  DatePicker.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 20.06.2025.
//

import SwiftUI

struct CustomDatePicker: View {
    @Binding var date: Date
    
    init(date: Binding<Date>) {
        self._date = date
    }
    
    var body: some View {
        HStack {
            Text(DateFormatters.dayMonth.string(from: date))
                .font(.system(size: 17, weight: .regular))
        }
        .padding(.horizontal, 12)
        .foregroundColor(.black)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.datePicker)
                .padding(.vertical, -8)
        )
        .overlay(
            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .colorMultiply(.clear)
        )
    }
}


#Preview {
    TransactionHistoryView(direction: .outcome)
}
