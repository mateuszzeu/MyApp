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
                Color.clear
                    .applyGradientBackground()

                VStack {
                    if viewModel.workoutDays.isEmpty {
                        Text("No workouts yet")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        Picker("Select Day", selection: $selectedDay) {
                            ForEach(viewModel.workoutDays) { day in
                                Text(day.dayName).tag(day.dayName)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()

                        ScrollView {
                            if let workoutDay = viewModel.workoutDays.first(where: { $0.dayName == selectedDay }) {
                                if !workoutDay.exercises.isEmpty {
                                    VStack {
                                        ForEach(Array(workoutDay.exercises.enumerated()), id: \.element.id) { index, exercise in
                                            ExerciseRowView(
                                                viewModel: viewModel,
                                                exercise: exercise,
                                                dayName: workoutDay.dayName,
                                                index: index
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
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
        ]),
        WorkoutDay(dayName: "Pull", exercises: [
            Exercise(name: "Deadlift", sets: "4", reps: "8", weight: "150kg", info: ""),
            Exercise(name: "Pull-up", sets: "4", reps: "10", weight: "Bodyweight", info: "")
        ])
    ]
    
    return WorkoutView(viewModel: viewModel)
}
