//
//  SuccessSheetView.swift
//  Stronger
//
//  Created by Liza on 05/01/2025.
//

import SwiftUI

struct SuccessSheetView: View {
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            LottieView(fileName: "Success", loopMode: .playOnce)

            Text("Your account has been created successfully!")
                .font(.headline)
                .foregroundColor(Color("TextColor"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                onDismiss()
            }) {
                Text("Go to Login")
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color("PrimaryColor"))
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .applyGradientBackground()
    }
}

#Preview {
    SuccessSheetView {
        print("Dismiss button tapped")
    }
}
