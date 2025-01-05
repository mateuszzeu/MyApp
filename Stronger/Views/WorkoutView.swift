//  ContentView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 18/10/2024.
//


import SwiftUI

struct WorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @State private var selectedDay: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    if viewModel.workoutDays.isEmpty {
                        Text("No workouts yet")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding()
                    } else {
                        WorkoutDaysScrollView(viewModel: viewModel, selectedDay: $selectedDay)

                        ScrollView {
                            if let workoutDay = viewModel.workoutDays.first(where: { $0.dayName == selectedDay }) {
                                WorkoutDayExercisesView(viewModel: viewModel, workoutDay: workoutDay)
                            }
                        }
                    }
                }
            }
            .applyGradientBackground()
            .navigationTitle("Workout Days")
        }
        .onAppear {
            viewModel.loadWorkoutDaysFromFirestore()
            if selectedDay.isEmpty, let firstDay = viewModel.workoutDays.first?.dayName {
                selectedDay = firstDay
            }
        }
    }
}


#Preview {
    let viewModel = WorkoutViewModel()
    
    viewModel.workoutDays = [
        WorkoutDay(dayName: "Push", exercises: [
            Exercise(name: "Bench Press", sets: "3", reps: "10", weight: "100kg", info: ""),
            Exercise(name: "Incline Dumbbell Press", sets: "3", reps: "12", weight: "80kg", info: "")
        ], order: 0),
        WorkoutDay(dayName: "Pull", exercises: [
            Exercise(name: "Deadlift", sets: "4", reps: "8", weight: "150kg", info: ""),
            Exercise(name: "Pull-up", sets: "4", reps: "10", weight: "Bodyweight", info: "")
        ], order: 1)
    ]
    
    return WorkoutView(viewModel: viewModel)
}


