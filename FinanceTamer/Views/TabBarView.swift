//
//  TabBarView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 20.06.2025.
//

import SwiftUI

struct TabBarView: View {
    init() {
        UITabBar.appearance().backgroundColor = .background
    }
    
    var body: some View {
        TabView {
            TransactionsListView(direction: .outcome)
                .tabItem {
                    Image("expenses")
                        .renderingMode(.template)
                    Text("Расходы")
                }

            TransactionsListView(direction: .income)
                .tabItem {
                    Image("incomes")
                        .renderingMode(.template)
                    Text("Доходы")
                }

            BankAccountView()
                .tabItem {
                    Image("bank_account")
                        .renderingMode(.template)
                    Text("Счет")
                }

            CategoriesListView()
                .tabItem {
                    Image("categories")
                        .renderingMode(.template)
                    Text("Статьи")
                }

            SettingsView()
                .tabItem {
                    Image("settings")
                        .renderingMode(.template)
                    Text("Настройки")
                }
        }
        .tint(.accentColor)
        .background(
            ShakeDetector {
                NotificationCenter.default.post(name: .shakeGesture, object: nil)
            }
        )
    }
}

extension Notification.Name {
    static let shakeGesture = Notification.Name("shakeGesture")
}

#Preview {
    TabBarView()
}
