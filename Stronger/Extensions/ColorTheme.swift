//
//  ColorTheme.swift
//  Stronger
//
//  Created by Liza on 20/02/2025.
//

import SwiftUI

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
