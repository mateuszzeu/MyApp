//
//  ViewModifiers.swift
//  Stronger
//
//  Created by Liza on 20/02/2025.
//

import SwiftUI

struct GradientBackground: ViewModifier {
    func body(content: Content) -> some View {
        LinearGradient(
            colors: [
                Color.theme.backgroundTop,
                Color.theme.backgroundBottom
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .overlay(content)
    }
}

struct TransparentBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(Color.theme.accent.opacity(0.15).blur(radius: 2))
            .cornerRadius(12)
            .shadow(color: Color.theme.text.opacity(0.1), radius: 5, x: 0, y: 5)
    }
}
