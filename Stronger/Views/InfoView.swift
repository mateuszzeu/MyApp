//
//  InfoView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 23/10/2024.
//

import SwiftUI

struct InfoView: View {
    @State var exercise: Exercise
    @ObservedObject var viewModel: WorkoutViewModel
    var dayName: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            TextEditor(text: Binding(
                get: { exercise.info },
                set: { newValue in
                    exercise.info = newValue
                    viewModel.updateExercise(dayName: dayName, exercise: exercise)
                }
            ))
            .scrollContentBackground(.hidden)
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
            .padding()
            .frame(minHeight: 150)
        }
        .applyGradientBackground()
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    InfoView(exercise: Exercise(name: "Squat", sets: "3", reps: "10", weight: "100", info: "Sample info"), viewModel: WorkoutViewModel(), dayName: "Push")
}
