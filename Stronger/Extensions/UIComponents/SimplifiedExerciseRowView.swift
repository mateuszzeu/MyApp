//
//  SimplifiedExerciseRowView.swift
//  Stronger
//
//  Created by Liza on 20/02/2025.
//

import SwiftUI

struct SimplifiedExerciseRowView: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.name)
                .font(.headline)
                .foregroundColor(Color.theme.text)
            
            ExerciseField(label: "Sets", value: .constant(exercise.sets))
                .disabled(true)
            ExerciseField(label: "Reps", value: .constant(exercise.reps))
                .disabled(true)
            ExerciseField(label: "Weight", value: .constant(exercise.weight))
                .disabled(true)
        }
        .padding()
        .background(Color.theme.primary.opacity(0.1))
        .cornerRadius(8)
    }
}
