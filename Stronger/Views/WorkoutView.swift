//
//  ContentView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 18/10/2024.
//

import SwiftUI

struct WorkoutView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.workoutDays.isEmpty {
                Text("No workouts yet")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(viewModel.workoutDays) { workoutDay in
                        Section(header: Text(workoutDay.dayName)) {
                            ForEach(workoutDay.exercises) { exercise in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(exercise.name)
                                        
                                        Text("Sets: \(exercise.sets), Reps: \(exercise.reps), Weight: \(exercise.weight)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Button(action: {
                                        // Szczegóły o ćwiczeniu
                                    }) {
                                        Image(systemName: "info.circle")
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Workout Days")
            }
        }
    }
}

#Preview {
    WorkoutView(viewModel: WorkoutViewModel())
}
