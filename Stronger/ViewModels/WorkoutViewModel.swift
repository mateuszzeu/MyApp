//
//  WorkoutViewModel.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 18/10/2024.
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

class WorkoutViewModel: ObservableObject {
    @Published var workoutDays: [WorkoutDay] = []
    private var db = Firestore.firestore()
    
    func addExercise(dayName: String, exerciseName: String, sets: String, reps: String, weight: String) {
        let newExercise = Exercise(name: exerciseName, sets: sets, reps: reps, weight: weight, info: "")
        
        if let index = workoutDays.firstIndex(where: { $0.dayName == dayName }) {
            workoutDays[index].exercises.append(newExercise)
        } else {
            let newDay = WorkoutDay(dayName: dayName, dateAdded: Date(), exercises: [newExercise])
            workoutDays.append(newDay)
            saveWorkoutDayToFirestore(newDay)
            return
        }
        
        if let day = workoutDays.first(where: { $0.dayName == dayName }) {
            saveWorkoutDayToFirestore(day)
        }
    }

    private func saveWorkoutDayToFirestore(_ workoutDay: WorkoutDay) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let workoutDayData: [String: Any] = [
            "dayName": workoutDay.dayName,
            "dateAdded": workoutDay.dateAdded,
            "exercises": workoutDay.exercises.map { [
                "name": $0.name,
                "sets": $0.sets,
                "reps": $0.reps,
                "weight": $0.weight,
                "info": $0.info
            ]}
        ]
        
        db.collection("users").document(userId).collection("workouts").document(workoutDay.dayName).setData(workoutDayData) { error in
            if let error = error {
                print("Błąd zapisu dnia treningowego: \(error.localizedDescription)")
            } else {
                print("Dzień treningowy zapisany poprawnie")
            }
        }
    }

    func deleteExercise(dayName: String, exerciseId: UUID) {
        guard let dayIndex = workoutDays.firstIndex(where: { $0.dayName == dayName }) else { return }

        if let exerciseIndex = workoutDays[dayIndex].exercises.firstIndex(where: { $0.id == exerciseId }) {
            workoutDays[dayIndex].exercises.remove(at: exerciseIndex)

            if workoutDays[dayIndex].exercises.isEmpty {
                removeDay(dayName: dayName)
            } else {
                saveWorkoutDayToFirestore(workoutDays[dayIndex])
            }
        }
    }


    func updateExercise(dayName: String, exercise: Exercise) {
        guard let dayIndex = workoutDays.firstIndex(where: { $0.dayName == dayName }) else { return }

        if let exerciseIndex = workoutDays[dayIndex].exercises.firstIndex(where: { $0.id == exercise.id }) {
            workoutDays[dayIndex].exercises[exerciseIndex] = exercise
            saveWorkoutDayToFirestore(workoutDays[dayIndex])
        }
    }


    func loadWorkoutDaysFromFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("workouts").getDocuments { snapshot, error in
            if let error {
                print("Błąd podczas pobierania danych: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            var fetchedWorkoutDays: [WorkoutDay] = []
            
            for document in documents {
                let data = document.data()
                guard let dayName = data["dayName"] as? String,
                      let exercisesData = data["exercises"] as? [[String: Any]],
                      let timestamp = data["dateAdded"] as? Timestamp
                else { continue }
                
                let dateAdded = timestamp.dateValue()
                
                var exercises: [Exercise] = []
                for exerciseData in exercisesData {
                    if let name = exerciseData["name"] as? String,
                       let sets = exerciseData["sets"] as? String,
                       let reps = exerciseData["reps"] as? String,
                       let weight = exerciseData["weight"] as? String,
                       let info = exerciseData["info"] as? String {
                        let exercise = Exercise(name: name, sets: sets, reps: reps, weight: weight, info: info)
                        exercises.append(exercise)
                    }
                }
                
                let workoutDay = WorkoutDay(dayName: dayName, dateAdded: dateAdded, exercises: exercises)
                fetchedWorkoutDays.append(workoutDay)
            }
            
            DispatchQueue.main.async {
                self.workoutDays = fetchedWorkoutDays
            }
        }
    }


    func moveExercise(dayName: String, fromIndex: Int, directionUp: Bool) {
        guard let dayIndex = workoutDays.firstIndex(where: { $0.dayName == dayName }) else { return }
        let targetIndex = directionUp ? fromIndex - 1 : fromIndex + 1
        guard targetIndex >= 0 && targetIndex < workoutDays[dayIndex].exercises.count else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            workoutDays[dayIndex].exercises.swapAt(fromIndex, targetIndex)
        }
        
        saveWorkoutDayToFirestore(workoutDays[dayIndex])
    }

    
    func addDay(dayName: String) {
        guard !dayName.isEmpty else { return }
        let newDay = WorkoutDay(dayName: dayName, dateAdded: Date(), exercises: [])
        workoutDays.append(newDay)
        saveWorkoutDayToFirestore(newDay)
    }
    
    func removeDay(dayName: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if let dayIndex = workoutDays.firstIndex(where: { $0.dayName == dayName }) {
            let dayToDelete = workoutDays[dayIndex]
            workoutDays.remove(at: dayIndex)
            
            db.collection("users").document(userId).collection("workouts").document(dayToDelete.dayName).delete { error in
                if let error = error {
                    print("Błąd usunięcia dnia: \(error.localizedDescription)")
                } else {
                    print("Dzień treningowy usunięty poprawnie")
                }
            }
        }
    }
}
