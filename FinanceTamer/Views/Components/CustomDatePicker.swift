//
//  DatePicker.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 20.06.2025.
//

import SwiftUI

struct CustomDatePicker: View {
    @Binding var date: Date
    @State private var displayDate: Date
    
    init(date: Binding<Date>) {
        self._date = date
        self._displayDate = State(initialValue: date.wrappedValue)
    }
    
    var body: some View {
        HStack {
            Text(DateFormatters.dayMonth.string(from: displayDate))
                .font(.system(size: 17, weight: .regular))
        }
        .padding(.horizontal, 12)
        .foregroundColor(.black)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(.datePicker)
                .opacity(0.5)
                .padding(.vertical, -8)
        )
        .overlay(
            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .colorMultiply(.clear)
        )
        .onChange(of: date) { newValue in
            displayDate = newValue
        }
    }
}


#Preview {
    TransactionHistoryView(direction: .outcome)
}
