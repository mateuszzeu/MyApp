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
import FirebaseStorage

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

        let newExercise = Exercise(name: exerciseName, sets: sets, reps: reps, weight: weight, info: "", imageURL: nil)

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
                "id": $0.id.uuidString,
                "name": $0.name,
                "sets": $0.sets,
                "reps": $0.reps,
                "weight": $0.weight,
                "info": $0.info,
                "imageURL": $0.imageURL ?? ""
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
        guard let exerciseIndex = workoutDays[dayIndex].exercises.firstIndex(where: { $0.id == exerciseId }) else { return }
        
        let exercise = workoutDays[dayIndex].exercises[exerciseIndex]
        
        if let imageURL = exercise.imageURL, !imageURL.isEmpty {
            deleteExerciseImage(imageURL: imageURL) { result in
                switch result {
                case .success:
                    self.removeExerciseFromFirestore(dayName: dayName, exerciseId: exerciseId, dayIndex: dayIndex, exerciseIndex: exerciseIndex)
                case .failure(let error):
                    print("❌ Nie można usunąć ćwiczenia – błąd usuwania zdjęcia: \(error.localizedDescription)")
                }
            }
        } else {
            removeExerciseFromFirestore(dayName: dayName, exerciseId: exerciseId, dayIndex: dayIndex, exerciseIndex: exerciseIndex)
        }
    }

    private func removeExerciseFromFirestore(dayName: String, exerciseId: UUID, dayIndex: Int, exerciseIndex: Int) {
        workoutDays[dayIndex].exercises.remove(at: exerciseIndex)

        if workoutDays[dayIndex].exercises.isEmpty {
            removeDay(dayName: dayName)
        } else {
            saveWorkoutDayToFirestore(workoutDays[dayIndex])
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
                      let order = data["order"] as? Int else { continue }
                
                var exercises: [Exercise] = []
                for exerciseData in exercisesData {
                    if let idString = exerciseData["id"] as? String,
                       let uuid = UUID(uuidString: idString),
                       let name = exerciseData["name"] as? String,
                       let sets = exerciseData["sets"] as? String,
                       let reps = exerciseData["reps"] as? String,
                       let weight = exerciseData["weight"] as? String,
                       let info = exerciseData["info"] as? String {
                        let imageURL = exerciseData["imageURL"] as? String
                        let exercise = Exercise(id: uuid, name: name, sets: sets, reps: reps, weight: weight, info: info, imageURL: imageURL)
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
                "exercises": day.exercises.map { exercise in
                    [
                        "id": exercise.id.uuidString,
                        "name": exercise.name,
                        "sets": exercise.sets,
                        "reps": exercise.reps,
                        "weight": exercise.weight,
                        "info": exercise.info,
                        "imageURL": exercise.imageURL ?? ""
                    ]
                }
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

            for exercise in dayToDelete.exercises {
                if let imageURL = exercise.imageURL, !imageURL.isEmpty {
                    deleteExerciseImage(imageURL: imageURL) { result in
                        switch result {
                        case .success:
                            print("✅ Zdjęcie \(imageURL) usunięte")
                        case .failure(let error):
                            print("⚠️ Nie udało się usunąć zdjęcia \(imageURL): \(error.localizedDescription)")
                        }
                    }
                }
            }

            workoutDays.remove(at: dayIndex)

            workoutDays.enumerated().forEach { index, day in
                workoutDays[index].order = index
            }

            saveWorkoutDaysOrder()

            db.collection("users").document(userId).collection("workouts").document(dayToDelete.dayName).delete { error in
                if let error = error {
                    print("❌ Błąd usunięcia dnia: \(error.localizedDescription)")
                } else {
                    print("✅ Dzień treningowy usunięty poprawnie")
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

    func uploadExerciseImage(dayName: String, exerciseId: UUID, imageData: Data?, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Brak użytkownika."])))
            return
        }
        guard let imageData = imageData, !imageData.isEmpty else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Obraz jest pusty!"])))
            return
        }

        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("exerciseImages/\(userId)/\(exerciseId).jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        imageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("❌ Błąd przesyłania zdjęcia: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("❌ Błąd pobierania URL: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else if let url = url {
                        print("✅ Zdjęcie przesłane pomyślnie: \(url.absoluteString)")

                        self.updateExerciseImage(dayName: dayName, exerciseId: exerciseId, imageURL: url.absoluteString)

                        completion(.success(url.absoluteString))
                    }
                }
            }
        }
    }




    
    func updateExerciseImage(dayName: String, exerciseId: UUID, imageURL: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let dayIndex = workoutDays.firstIndex(where: { $0.dayName == dayName }) else { return }
        guard let exerciseIndex = workoutDays[dayIndex].exercises.firstIndex(where: { $0.id == exerciseId }) else { return }

        workoutDays[dayIndex].exercises[exerciseIndex].imageURL = imageURL

        let exerciseRef = db.collection("users")
            .document(userId)
            .collection("workouts")
            .document(dayName)

        exerciseRef.updateData([
            "exercises.\(exerciseIndex).imageURL": imageURL
        ]) { error in
            if let error = error {
                print("❌ Błąd aktualizacji URL obrazu w Firestore: \(error.localizedDescription)")
            } else {
                print("✅ URL obrazu poprawnie zapisany w Firestore")
            }
        }
    }

    func deleteExerciseImage(imageURL: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Brak użytkownika."])))
            return
        }

        let storageRef = Storage.storage().reference()

        if let url = URL(string: imageURL),
           let lastPathComponent = url.lastPathComponent.removingPercentEncoding {

            let imageRef = storageRef.child("exerciseImages/\(userId)/\(lastPathComponent)")

            imageRef.delete { error in
                if let error = error {
                    print("❌ Błąd usuwania zdjęcia: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("✅ Zdjęcie usunięte pomyślnie")
                    completion(.success(()))
                }
            }
        } else {
            print("❌ Błąd parsowania URL obrazu do usunięcia")
            completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Błędny URL zdjęcia."])))
        }
    }


}
