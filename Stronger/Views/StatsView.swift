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
            List {
                Section(header: Text("Completed Workouts")) {
                    if statsViewModel.completedWorkouts.isEmpty {
                        Text("No workouts yet.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(statsViewModel.completedWorkouts) { workout in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(workout.workoutDayName)
                                    .font(.headline)
                                
                                Text("Date: \(workout.date.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                if let notes = workout.notes, !notes.isEmpty {
                                    Text("Notes: \(notes)")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Stats")
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
    StatsView()
}
