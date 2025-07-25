//
//  LaunchScreenView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 26.07.2025.
//


import SwiftUI

struct LaunchScreenView: View {
    @Binding var isAnimationFinished: Bool

    var body: some View {
        LottieView(animationName: "launchSrcreenAnimation") {
            isAnimationFinished = true
        }
        .ignoresSafeArea()
        .background(Color.lightGreen)
    }
}
