//
//  BankAccountView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 20.06.2025.
//

import SwiftUI

struct BankAccountView: View {
    @StateObject private var viewModel: BankAccountViewModel
    
    @State private var isEditing: Bool = false
    @State private var path = NavigationPath()
    @State private var showCurrencyPicker: Bool = false
    @State private var isBalanceHidden: Bool = false
    @State private var chartPeriod: BankAccountViewModel.Period = .daily
    
    init() {
        _viewModel = StateObject(wrappedValue: BankAccountViewModel())
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack {
                    List {
                        Section(header:
                                    Text("Мой счет")
                            .mainHeaderStyle()
                        ) {
                            HStack {
                                Text("💰")
                                    .font(.system(size: 20))
                                
                                Text("Баланс")
                                    .listRowStyle(.black)
                                
                                Spacer()
                                
                                if !isEditing {
                                    ZStack {
                                        if isBalanceHidden {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.black.opacity(0.08))
                                                .frame(width: 73, height: 20)
                                                .blur(radius: 3)
                                                .transition(.opacity)
                                        } else {
                                            Text("\(viewModel.balanceString) \(viewModel.selectedCurrency.symbol)")
                                                .listRowStyle(.black)
                                                .transition(.opacity)
                                        }
                                    }
                                    .frame(height: 20)
                                    .animation(.easeInOut(duration: 0.3), value: isBalanceHidden)
                                } else {
                                    TextField("Введите сумму", text: $viewModel.balanceString)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                        }
                        .listRowBackground(isEditing
                                           ? Color.white
                                           : Color.accentColor)
                        
                        Section {
                            HStack {
                                Text("Валюта")
                                    .listRowStyle(.black)
                                
                                Spacer()
                                
                                Text(viewModel.selectedCurrency.symbol)
                                    .listRowStyle(.black)
                            }
                            .onTapGesture {
                                if isEditing {
                                    showCurrencyPicker = true
                                }
                            }
                        }
                        .listRowBackground(isEditing
                                           ? Color.white
                                           : Color.lightGreen)
                        
                        if !isEditing {
                            Section {
                                Picker("Период", selection: $chartPeriod) {
                                    Text("По дням").tag(BankAccountViewModel.Period.daily)
                                    Text("По месяцам").tag(BankAccountViewModel.Period.monthly)
                                }
                                .pickerStyle(.segmented)
                                
                                BalanceChartView(points: viewModel.balancePoints(for: chartPeriod), period: chartPeriod)
                                    .background(Color.background)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                            .listRowBackground(Color.background)
                        }
                    }
                    .padding(.top, -14)
                    .listSectionSpacing(16)
                    .refreshable {
                        Task {
                            await viewModel.load()
                        }
                    }
                    .scrollDismissesKeyboard(.immediately)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if isEditing {
                            Button(action: {
                                Task {
                                    await viewModel.saveChanges()
                                    isEditing = false
                                    showCurrencyPicker = false
                                }
                                
                            }) {
                                HStack {
                                    Text("Сохранить")
                                }
                                .foregroundColor(.lightPurple)
                            }
                        } else {
                            Button(action: {
                                isEditing = true
                                isBalanceHidden = false
                            }) {
                                HStack {
                                    Text("Редактировать")
                                }
                                .foregroundColor(.lightPurple)
                            }
                        }
                    }
                }
                .popover(isPresented: $showCurrencyPicker) {
                    CurrencyPickerView(
                        selectedCurrency: $viewModel.selectedCurrency,
                        currencies: viewModel.availableCurrencies
                    )
                    .presentationDetents([.height(212)])
                    .background(Color.clear)
                    .presentationBackground(.clear)
                }
                .alert("Что-то не так", isPresented: $viewModel.showErrorAlert) {
                    Button("ОК", role: .cancel) {
                        viewModel.showErrorAlert = false
                    }
                } message: {
                    Text(viewModel.errorMessage ?? "Неизвестная ошибка")
                }
                
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .animation(.easeInOut, value: viewModel.isLoading)
        }
        .task {
            await viewModel.load()
        }
        .onReceive(NotificationCenter.default.publisher(for: .shakeGesture)) { _ in
            if !isEditing {
                withAnimation {
                    isBalanceHidden.toggle()
                }
            }
        }
    }
}

#Preview {
    BankAccountView()
}
