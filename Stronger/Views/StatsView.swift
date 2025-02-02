//
//  StatsView.swift
//  Stronger
//
//  Created by Liza on 14/01/2025.
//

import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    @ObservedObject var measurementsViewModel: MeasurementsViewModel
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    Text("Completed Workouts")
                        .font(.title2).bold()
                        .foregroundColor(Color.theme.text)
                        .padding(.top, 8)
                    
                    if viewModel.completedWorkouts.isEmpty {
                        Text("No workouts yet.")
                            .padding()
                            .foregroundColor(Color.theme.text.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(viewModel.completedWorkouts) { workout in
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
                        Spacer().frame(height: 20)
                    }
                    
                    Divider().padding(.vertical, 10)
                    
                    Text("Weight History")
                        .font(.title2).bold()
                        .foregroundColor(Color.theme.text)
                        .padding(.top, 10)
                    
                    if measurementsViewModel.dailyMeasurements.isEmpty {
                        Text("No weight records yet.")
                            .padding()
                            .foregroundColor(Color.theme.text.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(measurementsViewModel.dailyMeasurements) { measurement in
                            VStack {
                                Text("\(measurement.date.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.headline)
                                    .foregroundColor(Color.theme.text)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if let weight = measurement.weight {
                                    Text("Weight: \(String(format: "%.1f", weight)) kg")
                                        .font(.subheadline)
                                        .foregroundColor(Color.theme.text.opacity(0.7))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding()
                            .background(Color.theme.primary.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    Divider().padding(.vertical, 10)
                    
                    Text("Nutrition History")
                        .font(.title2).bold()
                        .foregroundColor(Color.theme.text)
                        .padding(.top, 10)
                    
                    if measurementsViewModel.dailyMeasurements.allSatisfy({ $0.macros == nil }) {
                        Text("No macro records yet.")
                            .padding()
                            .foregroundColor(Color.theme.text.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        ForEach(measurementsViewModel.dailyMeasurements) { measurement in
                            if let macros = measurement.macros {
                                VStack {
                                    Text("\(measurement.date.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.headline)
                                        .foregroundColor(Color.theme.text)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("Calories: \(Int(macros.calories)) kcal")
                                        .font(.footnote)
                                        .foregroundColor(Color.theme.text.opacity(0.6))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("Protein: \(Int(macros.protein)) g, Carbs: \(Int(macros.carbs)) g, Fat: \(Int(macros.fat)) g")
                                        .font(.footnote)
                                        .foregroundColor(Color.theme.text.opacity(0.6))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding()
                                .background(Color.theme.primary.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.top, 66)
            .safeAreaInset(edge: .bottom) {
                Spacer().frame(height: 120)
            }
        }
        .applyGradientBackground()
        .onAppear {
            viewModel.fetchCompletedWorkouts()
            measurementsViewModel.fetchDailyMeasurements()
        }
        .onDisappear {
            viewModel.stopListening()
            measurementsViewModel.stopListening()
        }
    }
}


#Preview {
    let statsViewModel = StatsViewModel()
    let measurementsViewModel = MeasurementsViewModel()
    
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
    
    measurementsViewModel.dailyMeasurements = [
        DailyMeasurement(
            date: Date(),
            weight: 70.5,
            macros: DailyMeasurement.Macros(
                protein: 150,
                carbs: 200,
                fat: 50,
                calories: 2500
            )
        ),
        DailyMeasurement(
            date: Date().addingTimeInterval(-86400),
            weight: 71.0,
            macros: DailyMeasurement.Macros(
                protein: 140,
                carbs: 210,
                fat: 55,
                calories: 2600
            )
        )
    ]
    
    return StatsView(measurementsViewModel: measurementsViewModel)
}
