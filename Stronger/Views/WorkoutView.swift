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
                        HStack(spacing: 8) {
                            ForEach(viewModel.workoutDays, id: \.id) { day in
                                Text(day.dayName)
                                    .font(.system(size: 14, weight: .medium))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(selectedDay == day.dayName ? Color.blue.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        selectedDay = day.dayName
                                    }
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal)

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
                                } else {
                                    Text("No exercises for this day")
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                            }
                        }
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
