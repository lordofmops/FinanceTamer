//
//  TabBarView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 20.06.2025.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
        TabView {
            ExpensesView()
                .tabItem {
                    Image("expenses")
                        .renderingMode(.template)
                    Text("Расходы")
                }

            IncomesView()
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

            CategoriesView()
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
    }
}

#Preview {
    TabBarView()
}
