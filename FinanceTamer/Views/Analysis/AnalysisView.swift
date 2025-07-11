//
//  AnalysisView.swift
//  FinanceTamer
//
//  Created by Дарья Дробышева on 11.07.2025.
//

import SwiftUI

struct AnalysisView: UIViewControllerRepresentable {
    let direction: Direction
    @Environment(\.presentationMode) var presentationMode
        
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    init(direction: Direction) {
        self.direction = direction
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let analysisVC = AnalysisViewController(direction: direction)
        
        let navController = UINavigationController(rootViewController: analysisVC)
        navController.navigationBar.tintColor = .lightPurple
        
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            primaryAction: UIAction { _ in
                context.coordinator.dismiss()
            },
            menu: nil
        )
        backButton.title = "Назад"
        backButton.tintColor = .lightPurple
        backButton.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17)], for: .normal)
        backButton.imageInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        analysisVC.navigationItem.leftBarButtonItem = backButton
        
        return navController
    }
    
    class Coordinator {
        var parent: AnalysisView
        
        init(_ parent: AnalysisView) {
            self.parent = parent
        }
        
        @objc func dismiss() {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
