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
    
    private var yAxisRange: ClosedRange<Decimal> {
        let maxValue = points.map { abs($0.balance) }.max() ?? 0
        return 0...max(maxValue, 1)
    }
    
    private var xAxisRange: ClosedRange<Date> {
        guard let firstDate = points.first?.date, let lastDate = points.last?.date else {
            return Date()...Date()
        }
        
        let lowerBound = min(firstDate, lastDate)
        let upperBound = max(firstDate, lastDate)
        
        return lowerBound...upperBound
    }
    
    var body: some View {
        Chart {
            let zeroBar = abs(points.filter { $0.balance != 0 }.min(by: { $0.balance < $1.balance })?.balance ?? 0) / 50
            ForEach(points) { point in
                BarMark(
                    x: .value("Дата", point.date),
                    y: .value("Баланс", point.balance == 0 ? zeroBar : abs(point.balance)),
                    width: 6
                )
                .foregroundStyle(point.isPositive ? .accent : .ftOrange)
                .cornerRadius(3)
            }
            
            if let selectedDate {
                RuleMark(x: .value("Selected", selectedDate))
                    .foregroundStyle(Color.gray)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    .annotation(position: .bottom) {
                        if let point = points.first(where: { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
                            Text("\(point.balance.formatted()) ₽")
                                .font(.caption)
                                .background(Color.accentColor)
                                .cornerRadius(4)
                        }
                    }
            }
        }
        .chartXScale(domain: xAxisRange)
        .chartYScale(domain: yAxisRange)
        .chartXSelection(value: $selectedDate)
        .chartXAxis {
            AxisMarks(
                values: .stride(
                    by: period == .daily ? .day : .month,
                    count: period == .daily ? 5 : 4
                )
            ) { value in
                AxisTick()
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        if period == .daily {
                            Text(date, format: .dateTime.day())
                                .font(.system(size: 8))
                        } else {
                            Text(date, format: .dateTime.month(.abbreviated))
                                .font(.system(size: 10))
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 240)
        .padding(.horizontal, 8)
    }
}

#Preview {
    BankAccountView()
}
