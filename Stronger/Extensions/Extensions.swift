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
    
    func applyTransparentBackground() -> some View {
        self.modifier(TransparentBackground())
    }
}


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


struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .applyTransparentBackground()
    }
}


struct WaterWave: Shape {
    var progress: CGFloat
    var waveHeight: CGFloat
    var offset: CGFloat
    
    var animatableData: CGFloat {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: .zero)
            
            let progressHeight: CGFloat = (1 - progress) * rect.height
            let height = waveHeight * rect.height
            
            for value in stride(from: 0, to: rect.width, by: 2) {
                let x: CGFloat = value
                let sine: CGFloat = sin(Angle(degrees: value + offset).radians)
                let y: CGFloat = progressHeight + (height * sine)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
    }
}

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let primary = Color("PrimaryColor")
    let accent = Color("AccentColor")
    let backgroundTop = Color("BackgroundTop")
    let backgroundBottom = Color("BackgroundBottom")
    let text = Color("TextColor")
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

struct TransparentButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.theme.text)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
        }
        .applyTransparentBackground()
    }
}
