//
//  SwiftUIView.swift
//  Stronger
//
//  Created by Liza on 04/01/2025.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var fileName: String
    var loopMode: LottieLoopMode = .loop
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: fileName)
        animationView.loopMode = loopMode
        animationView.play()
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        
    }
}

#Preview {
    LottieView(fileName: "CatAnimation", loopMode: .loop)
        .frame(width: 200, height: 200)
}


