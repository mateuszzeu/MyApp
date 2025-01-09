//
//
//  CustomTabBar.swift
//  Stronger
//
//  Created by Liza on 08/01/2025.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    var tabItems: [TabItem]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabItems) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 4) {
                        if selectedTab == tab {
                            Circle()
                                .fill(Color.purple.opacity(0.2))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.purple)
                                )
                        } else {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 0)
        )
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

#Preview {
    CustomTabBar(
        selectedTab: .constant(TabItem(icon: "house", title: "Home")),
        tabItems: [
            TabItem(icon: "house", title: "Home"),
            TabItem(icon: "heart", title: "Favorites"),
            TabItem(icon: "message", title: "Messages"),
            TabItem(icon: "person", title: "Profile")
        ]
    )
}
