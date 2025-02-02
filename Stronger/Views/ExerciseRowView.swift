//
//  ExerciseRowView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 29/10/2024.

import SwiftUI

struct ExerciseRowView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    
    let exercise: Exercise
    let dayName: String
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(Color.theme.text)
                
                Spacer()
                
                NavigationLink(destination: InfoView(exercise: exercise, viewModel: viewModel, dayName: dayName)) {
                    Image(systemName: "info.circle")
                        .foregroundColor(Color.theme.text)
                }
            }
            
            ExerciseField(label: "Sets", value: Binding(
                get: { exercise.sets },
                set: { newValue in
                    var updatedExercise = exercise
                    updatedExercise.sets = newValue
                    viewModel.updateExercise(dayName: dayName, exercise: updatedExercise)
                }
            ))
            
            ExerciseField(label: "Reps", value: Binding(
                get: { exercise.reps },
                set: { newValue in
                    var updatedExercise = exercise
                    updatedExercise.reps = newValue
                    viewModel.updateExercise(dayName: dayName, exercise: updatedExercise)
                }
            ))
            
            ExerciseField(label: "Weight", value: Binding(
                get: { exercise.weight },
                set: { newValue in
                    var updatedExercise = exercise
                    updatedExercise.weight = newValue
                    viewModel.updateExercise(dayName: dayName, exercise: updatedExercise)
                }
            ))
        }
        .padding()
        .applyTransparentBackground()
        .contextMenu {
            if index > 0 {
                Button("Move Up") {
                    viewModel.moveExercise(dayName: dayName, fromIndex: index, directionUp: true)
                }
            }
            if index < (viewModel.workoutDays.first { $0.dayName == dayName }?.exercises.count ?? 0) - 1 {
                Button("Move Down") {
                    viewModel.moveExercise(dayName: dayName, fromIndex: index, directionUp: false)
                }
            }
            
            Button("Delete") {
                viewModel.deleteExercise(dayName: dayName, exerciseId: exercise.id)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

#Preview {
    let viewModel = WorkoutViewModel()
    let exampleExercise = Exercise(name: "Squat", sets: "3", reps: "10", weight: "100kg", info: "Sample info")
    ExerciseRowView(viewModel: viewModel, exercise: exampleExercise, dayName: "Push", index: 0)
}


