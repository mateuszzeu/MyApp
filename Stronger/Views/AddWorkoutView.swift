//
//  AddWorkoutView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 18/10/2024.
//

import SwiftUI

struct AddWorkoutView: View {
    
    @ObservedObject var viewModel: WorkoutViewModel
    
    @State private var showDeleteDayAlert = false
    @State private var showValidationErrorAlert = false
    @State private var validationErrorMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        TextField("Enter New Day Name", text: $viewModel.newDayName)
                            .padding()
                            .applyTransparentBackground()
                        
                        Button(action: {
                            let result = viewModel.addDay(dayName: viewModel.newDayName)
                            if case .failure(let error) = result {
                                validationErrorMessage = error.localizedDescription
                                showValidationErrorAlert = true
                            }
                            viewModel.newDayName = ""
                            hideKeyboard()
                        }) {
                            Text("Add New Day")
                        }
                        .buttonStyle(CustomButtonStyle(
                            backgroundColor: viewModel.newDayName.isEmpty ? Color.theme.primary.opacity(0.4) : Color.theme.primary
                        ))
                        .disabled(viewModel.newDayName.isEmpty)
                    }
                    .padding()
                    
                    if !viewModel.workoutDays.isEmpty {
                        VStack(spacing: 10) {
                            Picker("Day", selection: $viewModel.selectedDay) {
                                ForEach(viewModel.workoutDays) { day in
                                    Text(day.dayName).tag(day.dayName)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            Button("Remove Selected Day") {
                                showDeleteDayAlert = true
                            }
                            .buttonStyle(CustomButtonStyle(
                                backgroundColor: viewModel.selectedDay.isEmpty ? Color.theme.primary.opacity(0.4) : Color.theme.accent.opacity(0.8)
                            ))
                            .disabled(viewModel.selectedDay.isEmpty)
                            .showConfirmationAlert(
                                isPresented: $showDeleteDayAlert,
                                title: "Delete Day",
                                message: "Are you sure you want to delete \(viewModel.selectedDay)?"
                            ) {
                                viewModel.removeDay(dayName: viewModel.selectedDay)
                                viewModel.selectedDay = viewModel.workoutDays.first?.dayName ?? ""
                            }
                        }
                        .padding()
                    }
                    
                    VStack(spacing: 10) {
                        CustomTextField(placeholder: "Exercise Name", text: $viewModel.exerciseName)
                        CustomTextField(placeholder: "Sets", text: $viewModel.sets)
                        CustomTextField(placeholder: "Reps", text: $viewModel.reps)
                        CustomTextField(placeholder: "Weight", text: $viewModel.weight)
                        
                        Button(action: {
                            let result = viewModel.addExercise()
                            switch result {
                            case .success:
                                clearFields()
                                hideKeyboard()
                            case .failure(let error):
                                validationErrorMessage = error.localizedDescription
                                showValidationErrorAlert = true
                            }
                        }) {
                            Text("Add Exercise")
                        }
                        .buttonStyle(CustomButtonStyle(
                            backgroundColor: [viewModel.exerciseName, viewModel.sets, viewModel.reps, viewModel.weight].contains(where: \.isEmpty) || viewModel.selectedDay.isEmpty ? Color.theme.primary.opacity(0.4) : Color.theme.accent,
                            foregroundColor: Color.theme.text
                        ))
                        .disabled([viewModel.exerciseName, viewModel.sets, viewModel.reps, viewModel.weight].contains(where: \.isEmpty) || viewModel.selectedDay.isEmpty)
                    }
                    .padding()
                    
                    Spacer()
                }
                .padding()
            }
            .applyGradientBackground()
            .alert("Validation Error", isPresented: $showValidationErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(validationErrorMessage)
            }
        }
    }
    
    private func clearFields() {
        viewModel.exerciseName = ""
        viewModel.sets = ""
        viewModel.reps = ""
        viewModel.weight = ""
    }
}


#Preview {
    AddWorkoutView(viewModel: WorkoutViewModel())
}
