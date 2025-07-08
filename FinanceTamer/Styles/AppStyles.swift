//
//  AppStyles.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 08.07.2025.
//

import SwiftUI

extension View {
    func mainHeaderStyle() -> some View {
        self
            .padding(.horizontal, -18)
            .font(.system(size: 34, weight: .bold))
            .foregroundColor(.header)
            .textCase(nil)
    }
    
    func listRowStyle(_ color: Color = .header) -> some View {
        self
            .font(.system(size: 17))
            .foregroundColor(color)
    }
    
    func emojiStyle() -> some View {
        self
            .font(.system(size: 14.5))
            .frame(width: 22, height: 22)
            .background(Color.lightGreen)
            .clipShape(Circle())
    }
}
