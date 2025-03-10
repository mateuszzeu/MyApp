//
//  Untitled.swift
//  Stronger
//
//  Created by Liza on 21/02/2025.
//

import SwiftUI

struct ErrorBannerView: View {
    @ObservedObject var errorHandler = ErrorHandler.shared

    var body: some View {
        if errorHandler.showError, let message = errorHandler.errorMessage {
            Text(message)
                .foregroundColor(.white)
                .padding()
                .background(Color.red.opacity(0.9))
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(maxWidth: .infinity)
        }
    }
}









