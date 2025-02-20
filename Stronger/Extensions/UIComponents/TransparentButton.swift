//
//  TransparentButton.swift
//  Stronger
//
//  Created by Liza on 20/02/2025.
//

import SwiftUI

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
