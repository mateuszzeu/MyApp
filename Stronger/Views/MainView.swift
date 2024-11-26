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
    
    var body: some View {
        ZStack {
            if !showSignInView {
                TabView {
                    WorkoutView(viewModel: viewModel)
                        .tabItem {
                            Label("Workouts", systemImage: "figure.strengthtraining.traditional")
                        }
                    
                    AddWorkoutView(workoutViewModel: viewModel)
                        .tabItem {
                            Label("Add Workout", systemImage: "square.and.pencil")
                        }
                    
                    ProgressView()
                        .tabItem {
                            Label("Hydration", systemImage: "heart")
                        }
                    
                    SettingsView(showSignInView: $showSignInView)
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
            }
        }
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
    MainView(viewModel: WorkoutViewModel())
}
