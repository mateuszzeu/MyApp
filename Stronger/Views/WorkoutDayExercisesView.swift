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
            }
            .padding(.horizontal)
        }
    }
}
