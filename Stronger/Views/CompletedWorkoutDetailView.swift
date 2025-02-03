//
//  CompletedWorkoutDetailView.swift
//  Stronger
//
//  Created by Liza on 16/01/2025.
//

import SwiftUI

struct CompletedWorkoutDetailView: View {
    let workout: CompletedWorkout

    var body: some View {
        ZStack {
            Color.clear
                .applyGradientBackground()
                .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    if workout.exercises.isEmpty {
                        Text("No exercises found")
                            .foregroundColor(Color.theme.text.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(workout.exercises) { exercise in
                            SimplifiedExerciseRowView(exercise: exercise)
                        }
                    }
                    Spacer().frame(height: 80)
                }
                .padding()
            }
        }
        .navigationTitle("Exercises for \(workout.workoutDayName)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let exampleExercise1 = Exercise(name: "Bench Press", sets: "3", reps: "10", weight: "80kg", info: "Keep elbows in")
    let exampleExercise2 = Exercise(name: "Incline Dumbbell Press", sets: "3", reps: "12", weight: "25kg per DB", info: "Focus on upper chest")

    let sampleWorkout = CompletedWorkout(
        date: Date(),
        workoutDayName: "Push Day",
        exercises: [exampleExercise1, exampleExercise2],
        notes: "Felt strong today!"
    )
    
    return NavigationStack {
        CompletedWorkoutDetailView(workout: sampleWorkout)
    }
}
