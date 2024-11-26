//
//  AddWorkoutView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 18/10/2024.
//

import SwiftUI

struct AddWorkoutView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    @State private var selectedDay: String = ""
    @State private var exerciseName: String = ""
    @State private var sets: String = ""
    @State private var reps: String = ""
    @State private var weight: String = ""
    @State private var newDayName: String = ""
    @State private var showDeleteDayAlert = false
    
    var body: some View {
        ZStack {
            Color.clear
                .applyGradientBackground()
            
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    TextField("Enter New Day Name", text: $newDayName)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                        .shadow(color: .gray.opacity(0.2), radius: 4)

                    Button(action: {
                        workoutViewModel.addDay(dayName: newDayName)
                        selectedDay = newDayName
                        newDayName = ""
                        hideKeyboard()
                    }) {
                        Text("Add New Day")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(newDayName.isEmpty ? Color.gray.opacity(0.5) : Color.teal)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(newDayName.isEmpty)
                }
                .padding()

                if !workoutViewModel.workoutDays.isEmpty {
                    VStack(spacing: 10) {
                        Picker("Day", selection: $selectedDay) {
                            ForEach(workoutViewModel.workoutDays) { day in
                                Text(day.dayName).tag(day.dayName)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Button("Remove Selected Day") {
                            showDeleteDayAlert = true
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedDay.isEmpty ? Color.gray.opacity(0.5) : Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(selectedDay.isEmpty)
                        .showConfirmationAlert(
                            isPresented: $showDeleteDayAlert,
                            title: "Delete Day",
                            message: "Are you sure you want to delete \(selectedDay)?"
                        ) {
                            workoutViewModel.removeDay(dayName: selectedDay)
                            selectedDay = workoutViewModel.workoutDays.first?.dayName ?? ""
                        }
                    }
                    .padding()
                }
                
                VStack(spacing: 10) {
                    CustomTextField(placeholder: "Exercise Name", text: $exerciseName)
                    CustomTextField(placeholder: "Sets", text: $sets)
                    CustomTextField(placeholder: "Reps", text: $reps)
                    CustomTextField(placeholder: "Weight", text: $weight)
                    
                    Button(action: {
                        workoutViewModel.addExercise(dayName: selectedDay, exerciseName: exerciseName, sets: sets, reps: reps, weight: weight)
                        clearFields()
                        hideKeyboard()
                    }) {
                        Text("Add Exercise")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.teal)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled([exerciseName, sets, reps, weight].contains(where: \.isEmpty))
                }
                .padding()

                Spacer()
            }
            .padding()
        }
    }
    
    private func clearFields() {
        exerciseName = ""
        sets = ""
        reps = ""
        weight = ""
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    AddWorkoutView(workoutViewModel: WorkoutViewModel())
}
