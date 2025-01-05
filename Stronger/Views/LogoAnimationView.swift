//
//  LogoAnimationView.swift
//  Stronger
//
//  Created by Liza on 04/01/2025.
//
import SwiftUI

struct LogoAnimationView: View {
    @State private var opacity = 0.0
    @State private var blur = 0.0
    var onAnimationEnd: () -> Void

    var body: some View {
        VStack {
            Spacer()

            Text("Fitally")
                .font(.largeTitle.bold())
                .foregroundColor(.black)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.0)) {
                        opacity = 1.0
                    }
                    withAnimation(.easeOut(duration: 1.0).delay(2.0)) {
                        opacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        onAnimationEnd()
                    }
                }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}


#Preview {
    LogoAnimationView {
        print("Animation finished")
    }
}






