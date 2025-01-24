//
//  MainView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 18/10/2024.
//
import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel = WorkoutViewModel()
    @State private var showSignInView: Bool = !UserDefaults.standard.bool(forKey: "isUserLoggedIn")
    @State private var selectedTab: TabItem = TabItem(icon: "figure.strengthtraining.traditional", title: "Workouts")
    
    private let tabItems: [TabItem] = [
        TabItem(icon: "figure.strengthtraining.traditional", title: "Workouts"),
        TabItem(icon: "square.and.pencil", title: "Add Workout"),
        TabItem(icon: "drop", title: "Hydration"),
        TabItem(icon: "chart.bar", title: "Stats"),
        TabItem(icon: "gear", title: "Settings")
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    switch selectedTab.title {
                    case "Workouts":
                        WorkoutView(viewModel: viewModel)
                    case "Add Workout":
                        AddWorkoutView(workoutViewModel: viewModel)
                    case "Hydration":
                        HydrationView(viewModel: viewModel)
                    case "Stats":
                        StatsView()
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
