//
//  ViewExtensions.swift
//  Stronger
//
//  Created by Liza on 20/02/2025.
//

import SwiftUI

extension View {
    func showConfirmationAlert(
        isPresented: Binding<Bool>,
        title: String = "Are you sure?",
        message: String = "Do you really want to delete this?",
        action: @escaping () -> Void
    ) -> some View {
        self.alert(isPresented: isPresented) {
            Alert(
                title: Text(title),
                message: Text(message),
                primaryButton: .destructive(Text("Confirm"), action: { action() }),
                secondaryButton: .cancel()
            )
        }
    }
    
    func applyGradientBackground() -> some View {
        self.modifier(GradientBackground())
    }
    
    func applyTransparentBackground() -> some View {
        self.modifier(TransparentBackground())
    }
    
    func hideKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
}
