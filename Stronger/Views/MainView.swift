//
//  MainView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 18/10/2024.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel = WorkoutViewModel()
    @StateObject private var weightViewModel = WeightViewModel()
    @StateObject private var macrosViewModel = MacrosViewModel()
    @State private var showSignInView: Bool = !UserDefaults.standard.bool(forKey: "isUserLoggedIn")
    @State private var selectedTab: TabItem = TabItem(icon: "figure.strengthtraining.traditional", title: "Workouts")
    
    private let tabItems: [TabItem] = [
        TabItem(icon: "figure.strengthtraining.traditional", title: "Workouts"),
        TabItem(icon: "dumbbell.fill", title: "Add Workout"),
        TabItem(icon: "drop.fill", title: "Hydration"),
        TabItem(icon: "chart.bar.xaxis", title: "Stats"),
        TabItem(icon: "plus.rectangle.fill.on.rectangle.fill", title: "Add Measurements"),
        TabItem(icon: "gearshape.fill", title: "Settings")
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    switch selectedTab.title {
                    case "Workouts":
                        WorkoutView(viewModel: viewModel)
                    case "Add Workout":
                        AddWorkoutView(viewModel: viewModel)
                    case "Hydration":
                        HydrationView(viewModel: viewModel)
                    case "Stats":
                        StatsView(weightViewModel: weightViewModel, macrosViewModel: macrosViewModel)
                    case "Add Measurements":
                        AddMeasurementsView(weightViewModel: weightViewModel, macrosViewModel: macrosViewModel)
                    case "Settings":
                        SettingsView(showSignInView: $showSignInView)
                    default:
                        WorkoutView(viewModel: viewModel)
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
            
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab, tabItems: tabItems)
                    .padding(.horizontal, 10)
            }
        }
        .background(Color.clear.ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
        .onAppear {
            updateSignInViewState()
        }
    }
    
    private func updateSignInViewState() {
        showSignInView = !UserDefaults.standard.bool(forKey: "isUserLoggedIn")
    }
}

#Preview {
    MainView()
}
