//
//  WorkoutDayExercisesView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 10/12/2024.
//

import SwiftUI

struct WorkoutDayExercisesView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @ObservedObject var infoViewModel: InfoViewModel
    var workoutDay: WorkoutDay

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
                        infoViewModel: infoViewModel,
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
    let infoViewModel = InfoViewModel()
    viewModel.workoutDays = [
        WorkoutDay(dayName: "Day one", exercises: [
            Exercise(name: "Push-ups", sets: "3", reps: "15", weight: "Bodyweight", info: ""),
            Exercise(name: "Pull-ups", sets: "3", reps: "10", weight: "Bodyweight", info: "")
        ], order: 0),
        WorkoutDay(dayName: "Day two", exercises: [], order: 1)
    ]

    return WorkoutDayExercisesView(viewModel: viewModel, infoViewModel: infoViewModel, workoutDay: viewModel.workoutDays[0])
}
