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

        let newExercise = Exercise(name: exerciseName, sets: sets, reps: reps, weight: weight, info: "", imageURLs: [])

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
                "imageURLs": $0.imageURLs ?? []
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
    
    func deleteExercise(dayName: String, exerciseId: UUID, infoViewModel: InfoViewModel) {
        guard let dayIndex = workoutDays.firstIndex(where: { $0.dayName == dayName }) else { return }
        guard let exerciseIndex = workoutDays[dayIndex].exercises.firstIndex(where: { $0.id == exerciseId }) else { return }

        let exercise = workoutDays[dayIndex].exercises[exerciseIndex]
        let imageURLs = exercise.imageURLs ?? []

        if !imageURLs.isEmpty {
            infoViewModel.deleteExerciseImages(dayName: dayName, exerciseId: exerciseId, imageURLs: imageURLs) { result in
                switch result {
                case .success:
                    print("✅ Exercise images deleted successfully")
                case .failure(let error):
                    print("⚠️ Failed to delete some images: \(error.localizedDescription)")
                }
                self.removeExerciseFromFirestore(dayName: dayName, exerciseId: exerciseId, dayIndex: dayIndex, exerciseIndex: exerciseIndex, infoViewModel: infoViewModel)
            }
        } else {
            removeExerciseFromFirestore(dayName: dayName, exerciseId: exerciseId, dayIndex: dayIndex, exerciseIndex: exerciseIndex, infoViewModel: infoViewModel)
        }
    }


    private func removeExerciseFromFirestore(dayName: String, exerciseId: UUID, dayIndex: Int, exerciseIndex: Int, infoViewModel: InfoViewModel) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let workoutRef = db.collection("users").document(userId).collection("workouts").document(dayName)

        workoutRef.getDocument { document, error in
            if let error = error {
                print("❌ Error fetching workout document: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("⚠️ Workout document \(dayName) not found.")
                return
            }
            
            guard var exercises = document.data()?["exercises"] as? [[String: Any]] else {
                print("⚠️ No exercises found in document \(dayName).")
                return
            }

            if let index = exercises.firstIndex(where: { $0["id"] as? String == exerciseId.uuidString }) {
                exercises.remove(at: index)

                workoutRef.updateData(["exercises": exercises]) { error in
                    if let error = error {
                        print("❌ Error updating Firestore after exercise deletion: \(error.localizedDescription)")
                    } else {
                        print("✅ Exercise removed from Firestore, now updating local model.")

                        DispatchQueue.main.async {
                            self.workoutDays[dayIndex].exercises.remove(at: exerciseIndex)

                            if self.workoutDays[dayIndex].exercises.isEmpty {
                                self.removeDay(dayName: dayName, infoViewModel: infoViewModel)
                            }
                        }
                    }
                }
            } else {
                print("⚠️ Exercise \(exerciseId) not found in Firestore.")
            }
        }
    }



    
    
    func updateExercise(dayName: String, exercise: Exercise) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let dayIndex = workoutDays.firstIndex(where: { $0.dayName == dayName }) else { return }
        guard let exerciseIndex = workoutDays[dayIndex].exercises.firstIndex(where: { $0.id == exercise.id }) else { return }

        let workoutRef = db.collection("users").document(userId).collection("workouts").document(dayName)

        workoutRef.getDocument { document, error in
            if let error = error {
                print("❌ Error fetching workout document: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("⚠️ Workout document \(dayName) not found.")
                return
            }

            guard var exercises = document.data()?["exercises"] as? [[String: Any]] else {
                print("⚠️ No exercises found in document \(dayName).")
                return
            }

            if let index = exercises.firstIndex(where: { $0["id"] as? String == exercise.id.uuidString }) {
                exercises[index] = [
                    "id": exercise.id.uuidString,
                    "name": exercise.name,
                    "sets": exercise.sets,
                    "reps": exercise.reps,
                    "weight": exercise.weight,
                    "info": exercise.info,
                    "imageURLs": exercise.imageURLs ?? []
                ]

                workoutRef.updateData(["exercises": exercises]) { error in
                    if let error = error {
                        print("❌ Error updating Firestore: \(error.localizedDescription)")
                    } else {
                        print("✅ Exercise updated in Firestore, now updating local model.")
                        DispatchQueue.main.async {
                            self.workoutDays[dayIndex].exercises[exerciseIndex] = exercise
                        }
                    }
                }
            } else {
                print("⚠️ Exercise \(exercise.id) not found in Firestore.")
            }
        }
    }

    
    
    func loadWorkoutDaysFromFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).collection("workouts").order(by: "order").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching workout days: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("⚠️ No workout days found in Firestore.")
                return
            }

            var fetchedWorkoutDays: [WorkoutDay] = []

            for document in documents {
                let data = document.data()
                
                guard let dayName = data["dayName"] as? String,
                      let exercisesData = data["exercises"] as? [[String: Any]],
                      let order = data["order"] as? Int else {
                    print("⚠️ Skipping invalid workout document: \(document.documentID)")
                    continue
                }

                var exercises: [Exercise] = []

                for exerciseData in exercisesData {
                    guard let idString = exerciseData["id"] as? String,
                          let uuid = UUID(uuidString: idString),
                          let name = exerciseData["name"] as? String,
                          let sets = exerciseData["sets"] as? String,
                          let reps = exerciseData["reps"] as? String,
                          let weight = exerciseData["weight"] as? String,
                          let info = exerciseData["info"] as? String else {
                        print("⚠️ Skipping invalid exercise data in \(dayName).")
                        continue
                    }

                    let imageURLs = exerciseData["imageURLs"] as? [String] ?? []
                    let exercise = Exercise(id: uuid, name: name, sets: sets, reps: reps, weight: weight, info: info, imageURLs: imageURLs)
                    exercises.append(exercise)
                }

                let workoutDay = WorkoutDay(dayName: dayName, exercises: exercises, order: order)
                fetchedWorkoutDays.append(workoutDay)
            }

            DispatchQueue.main.async {
                self.workoutDays = fetchedWorkoutDays.sorted(by: { $0.order < $1.order })
                print("✅ Successfully loaded \(self.workoutDays.count) workout days.")
            }
        }
    }


    
    
    
    func moveExercise(dayName: String, fromIndex: Int, directionUp: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let dayIndex = workoutDays.firstIndex(where: { $0.dayName == dayName }) else { return }
        
        let targetIndex = directionUp ? fromIndex - 1 : fromIndex + 1
        
        guard fromIndex >= 0, targetIndex >= 0,
              targetIndex < workoutDays[dayIndex].exercises.count else {
            print("⚠️ Invalid move: fromIndex=\(fromIndex), targetIndex=\(targetIndex)")
            return
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            workoutDays[dayIndex].exercises.swapAt(fromIndex, targetIndex)
        }

        let workoutRef = db.collection("users").document(userId).collection("workouts").document(dayName)

        workoutRef.getDocument { document, error in
            if let error = error {
                print("❌ Error fetching workout document \(dayName): \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists else {
                print("⚠️ Workout document \(dayName) not found in Firestore.")
                return
            }

            if var exercises = document.data()?["exercises"] as? [[String: Any]] {
                exercises.swapAt(fromIndex, targetIndex)

                workoutRef.updateData(["exercises": exercises]) { error in
                    if let error = error {
                        print("❌ Error updating Firestore after exercise move: \(error.localizedDescription)")
                    } else {
                        print("✅ Exercise moved successfully in Firestore.")
                    }
                }
            } else {
                print("⚠️ Exercises field missing or invalid in Firestore document \(dayName).")
            }
        }
    }
    


    
    func moveDay(fromIndex: Int, directionLeft: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let toIndex = directionLeft ? fromIndex - 1 : fromIndex + 1
        
        guard fromIndex >= 0, toIndex >= 0, toIndex < workoutDays.count else {
            print("⚠️ Invalid move: fromIndex=\(fromIndex), toIndex=\(toIndex)")
            return
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            workoutDays.swapAt(fromIndex, toIndex)
        }

        let workoutRef = db.collection("users").document(userId).collection("workouts")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            for (index, day) in self.workoutDays.enumerated() {
                self.workoutDays[index].order = index

                workoutRef.document(day.dayName).updateData(["order": index]) { error in
                    if let error = error {
                        print("❌ Error updating workout day order: \(error.localizedDescription)")
                    } else {
                        print("✅ Workout day order updated successfully for \(day.dayName)")
                    }
                }
            }
        }
    }

    
    
    func saveWorkoutDaysOrder() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let workoutRef = db.collection("users").document(userId).collection("workouts")
        var batch = db.batch()
        var hasChanges = false

        for (index, day) in workoutDays.enumerated() {
            if day.order != index {
                hasChanges = true
                workoutDays[index].order = index
                let docRef = workoutRef.document(day.dayName)
                batch.updateData(["order": index], forDocument: docRef)
            }
        }

        if hasChanges {
            batch.commit { error in
                if let error = error {
                    print("❌ Error updating workout day order: \(error.localizedDescription)")
                } else {
                    print("✅ Workout day order updated successfully")
                }
            }
        } else {
            print("⚠️ No order changes detected, skipping update.")
        }
    }

    
    
    
    func addDay(dayName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !dayName.isEmpty else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Day name cannot be empty."])))
            return
        }

        guard !workoutDays.contains(where: { $0.dayName == dayName }) else {
            completion(.failure(NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "A day with this name already exists."])))
            return
        }

        let newDay = WorkoutDay(dayName: dayName, exercises: [], order: workoutDays.count)
        workoutDays.append(newDay)
        
        saveWorkoutDayToFirestore(newDay)
        completion(.success(()))
    }



    
    func removeDay(dayName: String, infoViewModel: InfoViewModel) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        guard let dayIndex = workoutDays.firstIndex(where: { $0.dayName == dayName }) else {
            print("⚠️ Workout day not found in local model.")
            return
        }

        let dayToDelete = workoutDays[dayIndex]

        let allImageURLs = dayToDelete.exercises
            .compactMap { $0.imageURLs }
            .flatMap { $0 }

        let workoutRef = db.collection("users").document(userId).collection("workouts")
        let dayDocumentRef = workoutRef.document(dayToDelete.dayName)

        let deleteWorkoutDay = {
            let batch = self.db.batch()

            self.workoutDays.remove(at: dayIndex)

            for (index, day) in self.workoutDays.enumerated() {
                if day.order != index {
                    self.workoutDays[index].order = index
                    batch.updateData(["order": index], forDocument: workoutRef.document(day.dayName))
                }
            }

            batch.deleteDocument(dayDocumentRef)

            batch.commit { error in
                if let error = error {
                    print("❌ Error removing workout day: \(error.localizedDescription)")
                } else {
                    print("✅ Workout day removed and order updated successfully.")
                }
            }
        }

        if !allImageURLs.isEmpty {
            infoViewModel.deleteExerciseImages(dayName: dayName, exerciseId: nil as UUID?, imageURLs: allImageURLs) { result in
                switch result {
                case .success:
                    print("✅ All images for this day deleted successfully")
                    deleteWorkoutDay()
                case .failure(let error):
                    print("⚠️ Failed to delete some images: \(error.localizedDescription)")
                }
            }
        } else {
            deleteWorkoutDay()
        }
    }



    
    
    func loadHydrationData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("❌ Error loading hydration data: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists else {
                print("⚠️ Hydration data not found in Firestore.")
                return
            }

            if let data = document.data()?["hydration"] as? [String: Any] {
                DispatchQueue.main.async {
                    self.hydrationData.drinks = data["drinks"] as? [Double] ?? []
                    self.hydrationData.glassVolume = data["glassVolume"] as? Double ?? 250.0
                    self.hydrationData.dailyLimit = data["dailyLimit"] as? Double ?? 2000.0
                }
            } else {
                print("⚠️ Hydration data structure is missing in Firestore.")
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
                print("❌ Error saving hydration data: \(error.localizedDescription)")
            } else {
                print("✅ Hydration data saved successfully to Firestore.")
            }
        }
    }


    func uploadExerciseImage(dayName: String, exerciseId: UUID, imageData: Data?, infoViewModel: InfoViewModel, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "User not found."])))
            return
        }
        guard let imageData = imageData, !imageData.isEmpty else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Image data is empty."])))
            return
        }

        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("exerciseImages/\(userId)/\(UUID().uuidString).jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        imageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                print("❌ Error uploading image: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    print("❌ Error getting image URL: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let url = url else {
                    print("❌ Error: URL is nil after image upload.")
                    completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve image URL."])))
                    return
                }

                print("✅ Image uploaded successfully: \(url.absoluteString)")

                self.updateExerciseImage(dayName: dayName, exerciseId: exerciseId, imageURL: url.absoluteString)

                completion(.success(url.absoluteString))
            }
        }
    }

    
    func updateExerciseImage(dayName: String, exerciseId: UUID, imageURL: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ Error: No authenticated user.")
            return
        }
        guard let dayIndex = workoutDays.firstIndex(where: { $0.dayName == dayName }) else {
            print("⚠️ Error: Workout day '\(dayName)' not found.")
            return
        }
        guard let exerciseIndex = workoutDays[dayIndex].exercises.firstIndex(where: { $0.id == exerciseId }) else {
            print("⚠️ Error: Exercise with ID \(exerciseId) not found in local model.")
            return
        }

        DispatchQueue.main.async {
            if self.workoutDays[dayIndex].exercises[exerciseIndex].imageURLs == nil {
                self.workoutDays[dayIndex].exercises[exerciseIndex].imageURLs = []
            }
            self.workoutDays[dayIndex].exercises[exerciseIndex].imageURLs?.append(imageURL)
        }

        let exerciseRef = db.collection("users").document(userId).collection("workouts").document(dayName)

        exerciseRef.getDocument { document, error in
            if let error = error {
                print("❌ Error fetching Firestore document: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists else {
                print("⚠️ Error: Firestore document for '\(dayName)' does not exist.")
                return
            }

            if var exercises = document.data()?["exercises"] as? [[String: Any]] {
                if let index = exercises.firstIndex(where: { $0["id"] as? String == exerciseId.uuidString }) {
                    var updatedExercise = exercises[index]
                    
                    if var existingImageURLs = updatedExercise["imageURLs"] as? [String] {
                        existingImageURLs.append(imageURL)
                        updatedExercise["imageURLs"] = existingImageURLs
                    } else {
                        updatedExercise["imageURLs"] = [imageURL]
                    }

                    exercises[index] = updatedExercise

                    exerciseRef.updateData(["exercises": exercises]) { error in
                        if let error = error {
                            print("❌ Error updating Firestore exercise images: \(error.localizedDescription)")
                            
                            DispatchQueue.main.async {
                                self.workoutDays[dayIndex].exercises[exerciseIndex].imageURLs?.removeAll(where: { $0 == imageURL })
                            }
                        } else {
                            print("✅ Exercise images updated successfully in Firestore")
                        }
                    }
                } else {
                    print("⚠️ Error: Exercise with ID \(exerciseId) not found in Firestore.")
                }
            }
        }
    }
}
