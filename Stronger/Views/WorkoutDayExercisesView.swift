//
//  WorkoutDayExercisesView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 10/12/2024.
//

import SwiftUI

struct WorkoutDayExercisesView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    let workoutDay: WorkoutDay

    var body: some View {
        if workoutDay.exercises.isEmpty {
            Text("No exercises for this day")
                .foregroundColor(.gray)
                .padding()
        } else {
            VStack {
                ForEach(workoutDay.exercises) { exercise in
                    ExerciseRowView(
                        viewModel: viewModel,
                        exercise: exercise,
                        dayName: workoutDay.dayName,
                        index: workoutDay.exercises.firstIndex(of: exercise) ?? 0
                    )
                }
                Spacer().frame(height: 80)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    let viewModel = WorkoutViewModel()
    viewModel.workoutDays = [
        WorkoutDay(dayName: "Day one", exercises: [
            Exercise(name: "Push-ups", sets: "3", reps: "15", weight: "Bodyweight", info: ""),
            Exercise(name: "Pull-ups", sets: "3", reps: "10", weight: "Bodyweight", info: "")
        ], order: 0),
        WorkoutDay(dayName: "Day two", exercises: [], order: 1)
    ]
    
    return WorkoutDayExercisesView(
        viewModel: viewModel,
        workoutDay: viewModel.workoutDays[0]
    )
}
