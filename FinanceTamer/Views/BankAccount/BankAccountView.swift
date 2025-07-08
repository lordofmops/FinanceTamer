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
    
    @FocusState private var isBalanceFocused: Bool
    
    init() {
        _viewModel = StateObject(wrappedValue: BankAccountViewModel())
    }
    
    var body: some View {
        NavigationStack(path: $path) {
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
                                .keyboardType(.numbersAndPunctuation)
                                .multilineTextAlignment(.trailing)
                                .focused($isBalanceFocused)
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
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if isEditing {
                        isBalanceFocused = true
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        Button(action: {
                            Task {
                                await viewModel.saveChanges()
                                isEditing = false
                                isBalanceFocused = false
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
