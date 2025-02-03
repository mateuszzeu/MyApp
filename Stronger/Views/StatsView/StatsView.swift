//
//  StatsView.swift
//  Stronger
//
//  Created by Liza on 14/01/2025.
//

import SwiftUI

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()
    @ObservedObject var weightViewModel: WeightViewModel
    @ObservedObject var macrosViewModel: MacrosViewModel
    @ObservedObject var bodyMeasurementsViewModel: BodyMeasurementsViewModel
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
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

                    WeightHistoryView(weightViewModel: weightViewModel)
                    Divider().padding(.vertical, 10)

                    MacrosHistoryView(macrosViewModel: macrosViewModel)
                    Divider().padding(.vertical, 10)

                    BodyMeasurementsHistoryView(bodyMeasurementsViewModel: bodyMeasurementsViewModel)
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
            weightViewModel.fetchDailyWeights()
            macrosViewModel.fetchDailyMacros()
            bodyMeasurementsViewModel.fetchMeasurements()
        }
        .onDisappear {
            viewModel.stopListening()
            weightViewModel.stopListening()
            macrosViewModel.stopListening()
            bodyMeasurementsViewModel.stopListening()
        }
    }
}


