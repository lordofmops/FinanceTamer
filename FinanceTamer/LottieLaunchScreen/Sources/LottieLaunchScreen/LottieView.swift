//
//  LottieView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 26.07.2025.
//


import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .playOnce
    var onFinished: (() -> Void)? = nil

    func makeUIView(context: Context) -> some UIView {
        let view = UIView()

        let animationView = LottieAnimationView(name: animationName)
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        animationView.play { finished in
            if finished {
                onFinished?()
            }
        }

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
