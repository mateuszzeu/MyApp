//
//  StatsView.swift
//  Stronger
//
//  Created by Liza on 14/01/2025.
//

import SwiftUI

struct StatsView: View {
    @StateObject private var statsViewModel = StatsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.clear
                    .applyGradientBackground()
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack {
                        if statsViewModel.completedWorkouts.isEmpty {
                            Text("No workouts yet.")
                                .padding()
                                .foregroundColor(Color.theme.text.opacity(0.5))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            ForEach(statsViewModel.completedWorkouts) { workout in

                                NavigationLink(destination: CompletedWorkoutDetailView(workout: workout)) {

                                    VStack {
                                        Text(workout.workoutDayName)
                                            .font(.headline)
                                            .foregroundColor(Color.theme.text)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text("Date: \(workout.date.formatted(date: .abbreviated, time: .shortened))")
                                            .font(.subheadline)
                                            .foregroundColor(Color.theme.text.opacity(0.7))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        if let notes = workout.notes, !notes.isEmpty {
                                            Text("Notes: \(notes)")
                                                .font(.footnote)
                                                .foregroundColor(Color.theme.text.opacity(0.6))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    .padding()
                                    .background(Color.theme.primary.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    //.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("Statistics")
            .onAppear {
                statsViewModel.fetchCompletedWorkouts()
            }
            .onDisappear {
                statsViewModel.stopListening()
            }
        }
    }
}

#Preview {
    let statsViewModel = StatsViewModel()
    statsViewModel.completedWorkouts = [
        CompletedWorkout(
            date: Date(),
            workoutDayName: "Push Day",
            exercises: [],
            notes: "Great session today!"
        ),
        CompletedWorkout(
            date: Date().addingTimeInterval(-86400),
            workoutDayName: "Leg Day",
            exercises: [],
            notes: "Tough but worth it."
        )
    ]
    return StatsView()
}
