//
//  BalanceChartView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 25.07.2025.
//

import SwiftUI
import Charts

struct BalanceChartView: View {
    let points: [BalancePoint]
    let period: BankAccountViewModel.Period
    @State private var selectedDate: Date?

    var body: some View {
        Chart {
            ForEach(points) { point in
                BarMark(
                    x: .value("Дата", point.date),
                    y: .value("Баланс", point.balance)
                )
                .foregroundStyle(point.isPositive ? .ftOrange : .accent)
                .cornerRadius(3)
            }

            if let selectedDate {
                RuleMark(x: .value("Selected", selectedDate))
                    .foregroundStyle(Color.gray)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    .annotation(position: .bottom, alignment: .center) {
                        if let point = points.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                            Text("\(point.balance.formatted()) ₽")
                                .font(.caption)
                                .padding(4)
                                .background(Color.accentColor)
                        }
                    }
            }
        }
        .chartXSelection(value: $selectedDate)
        .chartXAxis {
            AxisMarks(values: .stride(by: period == .daily ? .day : .month, count: 1)) { value in
                AxisTick()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(period == .daily
                             ? date.formatted(.dateTime.day().month(.narrow))
                             : date.formatted(.dateTime.month(.abbreviated).year()))
                    }
                }
                .font(.system(size: 8))
            }
        }
        .frame(maxWidth: .infinity, idealHeight: 240)
        .padding(.horizontal)
        .animation(.easeInOut, value: points)
    }
}

#Preview {
    BankAccountView()
}
