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
    
    @State private var showAlert = false
    @State private var showDeleteDayAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Create New Day")) {
                TextField("Enter New Day Name", text: $newDayName)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                Button("Add New Day") {
                    if !newDayName.isEmpty {
                        workoutViewModel.addDay(dayName: newDayName)
                        selectedDay = newDayName
                        newDayName = ""
                        }
                    }
                    .disabled(newDayName.isEmpty)
            }
            
            if !workoutViewModel.workoutDays.isEmpty {
                Section(header: Text("Select Day")) {
                    Picker("Day", selection: $selectedDay) {
                        ForEach(workoutViewModel.workoutDays) { day in
                            Text(day.dayName).tag(day.dayName)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            
            Button("Remove Selected Day") {
                showDeleteDayAlert = true
            }
            .foregroundColor(.red)
            .disabled(selectedDay.isEmpty)
            .showConfirmationAlert(isPresented: $showDeleteDayAlert) {
                workoutViewModel.removeDay(dayName: selectedDay)
                selectedDay = workoutViewModel.workoutDays.first?.dayName ?? ""
            }
            
            Section(header: Text("Exercise Details")) {
                TextField("Exercise Name", text: $exerciseName)
                TextField("Sets", text: $sets)
                TextField("Reps", text: $reps)
                TextField("Weight", text: $weight)
            }
            
            Button("Add Exercise") {
                if [exerciseName, sets, reps, weight].contains(where: \.isEmpty) {
                    showAlert = true
                } else {
                    workoutViewModel.addExercise(dayName: selectedDay, exerciseName: exerciseName, sets: sets, reps: reps, weight: weight)
                    clearFields()
                    hideKeyboard()
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .scrollContentBackground(.hidden)
        .applyGradientBackground()
        .navigationTitle("Add Workout")
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Incomplete Fields"), message: Text("Please fill all fields."))
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
    AddWorkoutView(workoutViewModel: WorkoutViewModel())  // Przekazujemy AddWorkoutViewModel
}
