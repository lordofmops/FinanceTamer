//
//  FinanceTamerApp.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 12.06.2025.
//

import SwiftUI

@main
struct FinanceTamerApp: App {
    @State private var isAnimationFinished = false
    
    var body: some Scene {
        WindowGroup {
            if isAnimationFinished {
                TabBarView() 
            } else {
                LaunchScreenView(isAnimationFinished: $isAnimationFinished)
            }
        }
    }
}

#Preview {
    TabBarView()
}
