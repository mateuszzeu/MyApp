//
//  MainView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 18/10/2024.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    @ObservedObject var viewModel = WorkoutViewModel()
    @ObservedObject var infoViewModel = InfoViewModel()
    
    @StateObject private var weightViewModel = WeightViewModel()
    @StateObject private var macrosViewModel = MacrosViewModel()
    @StateObject private var bodyMeasurementsViewModel = BodyMeasurementsViewModel()
    
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
                        WorkoutView(viewModel: viewModel, infoViewModel: infoViewModel)
                    case "Add Workout":
                        AddWorkoutView(viewModel: viewModel)
                    case "Hydration":
                        HydrationView(viewModel: viewModel)
                    case "Stats":
                        StatsView(weightViewModel: weightViewModel, macrosViewModel: macrosViewModel, bodyMeasurementsViewModel: bodyMeasurementsViewModel)
                    case "Add Measurements":
                        AddMeasurementsView(weightViewModel: weightViewModel, macrosViewModel: macrosViewModel, bodyMeasurementsViewModel: bodyMeasurementsViewModel)
                    case "Settings":
                        SettingsView()
                    default:
                        WorkoutView(viewModel: viewModel, infoViewModel: infoViewModel)
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
        .fullScreenCover(isPresented: Binding(
            get: { !authViewModel.isUserLoggedIn },
            set: { authViewModel.isUserLoggedIn = !$0 }
        )) {
            NavigationStack {
                AuthenticationView()
                    .environmentObject(authViewModel)
            }
        }
        .onAppear {
            authViewModel.checkAuthenticationStatus()
        }
        .onChange(of: authViewModel.isUserLoggedIn) {
            if authViewModel.isUserLoggedIn {
                selectedTab = TabItem(icon: "figure.strengthtraining.traditional", title: "Workouts")
            }
        }
    }
}

#Preview {
    MainView()
}
