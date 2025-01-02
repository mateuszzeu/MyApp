//
//  CustomButtonStyle.swift
//  Stronger
//
//  Created by Liza on 02/01/2025.
//

import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    var backgroundColor: Color = Color.teal
    var foregroundColor: Color = .white
    var cornerRadius: CGFloat = 10
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(configuration.isPressed ? backgroundColor.opacity(0.7) : backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
