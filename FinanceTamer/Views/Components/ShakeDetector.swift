//
//  ShakeDetectorWindow.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 27.06.2025.
//

import SwiftUI
import UIKit

struct ShakeDetector: UIViewControllerRepresentable {
    var onShake: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        ShakeHostingController(onShake: onShake)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        uiViewController.becomeFirstResponder()
    }

    class ShakeHostingController: UIViewController {
        let onShake: () -> Void

        init(onShake: @escaping () -> Void) {
            self.onShake = onShake
            super.init(nibName: nil, bundle: nil)
            becomeFirstResponder()
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            becomeFirstResponder()
        }

        required init?(coder: NSCoder) { fatalError() }

        override var canBecomeFirstResponder: Bool { true }

        override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
                onShake()
            }
        }
    }
}

extension View {
    func onShake(perform: @escaping () -> Void) -> some View {
        self.background(ShakeDetector(onShake: perform))
    }
}

