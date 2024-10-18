//
//  AddWorkoutView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 18/10/2024.
//

import SwiftUI

struct AddWorkoutView: View {
    var body: some View {
        Form {
            // Picker do wyboru dnia treningowego
            Section(header: Text("Select Day")) {
                Picker("Day", selection: $selectedDay) {
                    Text("Pull").tag("Pull")
                    Text("Push").tag("Push")
                    Text("Legs").tag("Legs")
                    Text("FBW").tag("FBW")
                }
                .pickerStyle(SegmentedPickerStyle())  // Picker w formie przycisków
            }
            
            // Pola do wprowadzania danych o nowym ćwiczeniu
            Section(header: Text("Exercise Details")) {
                TextField("Exercise Name", text: $exerciseName)
                TextField("Sets", text: $sets)
                TextField("Reps", text: $reps)
                TextField("Weight", text: $weight)
            }
            
            // Przycisk do dodania ćwiczenia
            Button(action: {
                addExercise()
            }) {
                Text("Add Exercise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .navigationTitle("Add Workout")
    }
    
    // Logika dodawania ćwiczenia
    private func addExercise() {
        let newExercise = Exercise(name: exerciseName, sets: sets, reps: reps, weight: weight, info: "")
        
        // Sprawdzamy, czy wybrany dzień treningowy już istnieje
        if let index = viewModel.workoutDays.firstIndex(where: { $0.dayName == selectedDay }) {
            // Jeśli dzień istnieje, dodajemy do niego ćwiczenie
            viewModel.workoutDays[index].exercises.append(newExercise)
        } else {
            // Jeśli dzień nie istnieje, tworzymy nowy dzień treningowy
            let newDay = WorkoutDay(dayName: selectedDay, exercises: [newExercise])
            viewModel.workoutDays.append(newDay)
        }
    }
}

#Preview {
    AddWorkoutView()
}
