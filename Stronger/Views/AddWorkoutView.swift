//
//  AddWorkoutView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 18/10/2024.
//

import SwiftUI

struct AddWorkoutView: View {
    
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    @State private var showDeleteDayAlert = false
    @State private var showValidationErrorAlert = false
    @State private var validationErrorMessage = ""

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    VStack(spacing: 10) {
                        TextField("Enter New Day Name", text: $workoutViewModel.newDayName)
                            .padding()
                            .applyTransparentBackground()
                        
                        Button(action: {
                            let result = workoutViewModel.addDay(dayName: workoutViewModel.newDayName)
                            if case .failure(let error) = result {
                                validationErrorMessage = error.localizedDescription
                                showValidationErrorAlert = true
                            }
                            workoutViewModel.newDayName = ""
                            hideKeyboard()
                        }) {
                            Text("Add New Day")
                        }
                        .buttonStyle(CustomButtonStyle(
                            backgroundColor: workoutViewModel.newDayName.isEmpty ? Color.theme.primary.opacity(0.4) : Color.theme.primary
                        ))
                        .disabled(workoutViewModel.newDayName.isEmpty)
                    }
                    .padding()
                    
                    if !workoutViewModel.workoutDays.isEmpty {
                        VStack(spacing: 10) {
                            Picker("Day", selection: $workoutViewModel.selectedDay) {
                                ForEach(workoutViewModel.workoutDays) { day in
                                    Text(day.dayName).tag(day.dayName)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            Button("Remove Selected Day") {
                                showDeleteDayAlert = true
                            }
                            .buttonStyle(CustomButtonStyle(
                                backgroundColor: workoutViewModel.selectedDay.isEmpty ? Color.theme.primary.opacity(0.4) : Color.theme.accent.opacity(0.8)
                            ))
                            .disabled(workoutViewModel.selectedDay.isEmpty)
                            .showConfirmationAlert(
                                isPresented: $showDeleteDayAlert,
                                title: "Delete Day",
                                message: "Are you sure you want to delete \(workoutViewModel.selectedDay)?"
                            ) {
                                workoutViewModel.removeDay(dayName: workoutViewModel.selectedDay)
                                workoutViewModel.selectedDay = workoutViewModel.workoutDays.first?.dayName ?? ""
                            }
                        }
                        .padding()
                    }
                    
                    VStack(spacing: 10) {
                        CustomTextField(placeholder: "Exercise Name", text: $workoutViewModel.exerciseName)
                        CustomTextField(placeholder: "Sets", text: $workoutViewModel.sets)
                        CustomTextField(placeholder: "Reps", text: $workoutViewModel.reps)
                        CustomTextField(placeholder: "Weight", text: $workoutViewModel.weight)
                        
                        Button(action: {
                            let result = workoutViewModel.addExercise()
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
                            backgroundColor: [workoutViewModel.exerciseName, workoutViewModel.sets, workoutViewModel.reps, workoutViewModel.weight].contains(where: \.isEmpty) || workoutViewModel.selectedDay.isEmpty ? Color.theme.primary.opacity(0.4) : Color.theme.accent,
                            foregroundColor: Color.theme.text
                        ))
                        .disabled([workoutViewModel.exerciseName, workoutViewModel.sets, workoutViewModel.reps, workoutViewModel.weight].contains(where: \.isEmpty) || workoutViewModel.selectedDay.isEmpty)
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
        workoutViewModel.exerciseName = ""
        workoutViewModel.sets = ""
        workoutViewModel.reps = ""
        workoutViewModel.weight = ""
    }
}


#Preview {
    AddWorkoutView(workoutViewModel: WorkoutViewModel())
}
