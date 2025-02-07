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
    @Published var hydrationData: HydrationData = HydrationData()
    
    @Published var selectedDay: String = ""
    @Published var exerciseName: String = ""
    @Published var sets: String = ""
    @Published var reps: String = ""
    @Published var weight: String = ""
    @Published var newDayName: String = ""
    
    var isTesting = false
    private var db = Firestore.firestore()
    
    func addExercise() -> Result<Void, Error> {
        guard !selectedDay.isEmpty else {
            return .failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Nie wybrano dnia."]))
        }
        guard !exerciseName.isEmpty, !sets.isEmpty, !reps.isEmpty, !weight.isEmpty else {
            return .failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Nie wszystkie pola są wypełnione."]))
        }

        let newExercise = Exercise(name: exerciseName, sets: sets, reps: reps, weight: weight, info: "")

        if let index = workoutDays.firstIndex(where: { $0.dayName == selectedDay }) {
            workoutDays[index].exercises.append(newExercise)
            saveWorkoutDayToFirestore(workoutDays[index])
        } else {
            let newDay = WorkoutDay(dayName: selectedDay, exercises: [newExercise], order: workoutDays.count)
            workoutDays.append(newDay)
            saveWorkoutDayToFirestore(newDay)
        }

        return .success(())
    }

    
    private func saveWorkoutDayToFirestore(_ workoutDay: WorkoutDay) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let workoutDayData: [String: Any] = [
            "dayName": workoutDay.dayName,
            "order": workoutDay.order,
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
        
        db.collection("users").document(userId).collection("workouts").order(by: "order").getDocuments { snapshot, error in
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
                      let order = data["order"] as? Int
                else { continue }
                
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
                
                let workoutDay = WorkoutDay(dayName: dayName, exercises: exercises, order: order)
                fetchedWorkoutDays.append(workoutDay)
            }
            
            DispatchQueue.main.async {
                self.workoutDays = fetchedWorkoutDays.sorted(by: { $0.order < $1.order })
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
    
    func moveDay(fromIndex: Int, directionLeft: Bool) {
        let toIndex = directionLeft ? fromIndex - 1 : fromIndex + 1
        guard toIndex >= 0 && toIndex < workoutDays.count else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            workoutDays.swapAt(fromIndex, toIndex)
        }
        
        if isTesting {
            self.workoutDays.enumerated().forEach { index, day in
                self.workoutDays[index].order = index
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.workoutDays.enumerated().forEach { index, day in
                    self.workoutDays[index].order = index
                }
                self.saveWorkoutDaysOrder()
            }
        }
    }
    
    
    
    func saveWorkoutDaysOrder() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        for day in workoutDays {
            let workoutDayData: [String: Any] = [
                "dayName": day.dayName,
                "order": day.order,
                "exercises": day.exercises.map { [
                    "name": $0.name,
                    "sets": $0.sets,
                    "reps": $0.reps,
                    "weight": $0.weight,
                    "info": $0.info
                ]}
            ]
            
            db.collection("users").document(userId).collection("workouts").document(day.dayName).setData(workoutDayData) { error in
                if let error = error {
                    print("Błąd zapisu dnia treningowego: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    
    func addDay(dayName: String) -> Result<Void, Error> {
        guard !dayName.isEmpty else {
            return .failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Nazwa dnia nie może być pusta."]))
        }

        let newDay = WorkoutDay(dayName: dayName, exercises: [], order: workoutDays.count)
        workoutDays.append(newDay)
        saveWorkoutDayToFirestore(newDay)

        return .success(())
    }
    
    func removeDay(dayName: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        if let dayIndex = workoutDays.firstIndex(where: { $0.dayName == dayName }) {
            let dayToDelete = workoutDays[dayIndex]
            workoutDays.remove(at: dayIndex)
            
            workoutDays.enumerated().forEach { index, day in
                workoutDays[index].order = index
            }
            
            saveWorkoutDaysOrder()
            
            db.collection("users").document(userId).collection("workouts").document(dayToDelete.dayName).delete { error in
                if let error = error {
                    print("Błąd usunięcia dnia: \(error.localizedDescription)")
                } else {
                    print("Dzień treningowy usunięty poprawnie")
                }
            }
        }
    }
    
    
    func loadHydrationData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Błąd podczas ładowania danych nawodnienia: \(error.localizedDescription)")
                return
            }
            
            if let data = document?.data()?["hydration"] as? [String: Any] {
                DispatchQueue.main.async {
                    if let drinksArray = data["drinks"] as? [Double] {
                        self.hydrationData.drinks = drinksArray
                    }
                    if let glassVolume = data["glassVolume"] as? Double {
                        self.hydrationData.glassVolume = glassVolume
                    }
                    if let limit = data["dailyLimit"] as? Double {
                        self.hydrationData.dailyLimit = limit
                    }
                }
            }
        }
    }
    
    func saveHydrationData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let hydrationDict: [String: Any] = [
            "drinks": hydrationData.drinks,
            "glassVolume": hydrationData.glassVolume,
            "dailyLimit": hydrationData.dailyLimit
        ]
        
        db.collection("users").document(userId).setData(["hydration": hydrationDict], merge: true) { error in
            if let error = error {
                print("Błąd podczas zapisu danych nawodnienia: \(error.localizedDescription)")
            }
        }
    }
}
