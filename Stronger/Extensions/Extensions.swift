//
//  Extensions.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 07/11/2024.
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
}
    

struct GradientBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            content
        }
    }
}
