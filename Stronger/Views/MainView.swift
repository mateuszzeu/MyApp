//
//  MainView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 18/10/2024.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel = WorkoutViewModel()
    
    var body: some View {
        TabView {
            WorkoutView(viewModel: viewModel)
                .tabItem {
                    Label("Workouts", systemImage: "dumbell")
                }
            
            AddWorkoutView(viewModel: viewModel)
                .tabItem {
                    Label("Add Workout", systemImage: "plus")
                }
        }
    }
}

#Preview {
    MainView(viewModel: WorkoutViewModel())
}
