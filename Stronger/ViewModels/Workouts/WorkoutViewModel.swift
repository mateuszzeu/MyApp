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
    
    // var isTesting = false
    private var db = Firestore.firestore()
    
    
    
    // MARK: - ADD
    
    func addExercise() -> Result<Void, Error> {
        guard !selectedDay.isEmpty else {
            return .failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No day picked."]))
        }
        guard !exerciseName.isEmpty, !sets.isEmpty, !reps.isEmpty, !weight.isEmpty else {
            return .failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Some forms are empty."]))
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
    
    
    
    // MARK: - DELETE
    
    func deleteExercise(dayName: String, exerciseId: UUID, infoViewModel: InfoViewModel) {
        guard let dayIndex = workoutDays.firstIndex(where: { $0.dayName == dayName }) else { return }
        guard let exerciseIndex = workoutDays[dayIndex].exercises.firstIndex(where: { $0.id == exerciseId }) else { return }
        
        let exercise = workoutDays[dayIndex].exercises[exerciseIndex]
        let imageURLs = exercise.imageURLs ?? []
        
        if !imageURLs.isEmpty {
            infoViewModel.deleteExerciseImages(dayName: dayName, exerciseId: exerciseId, imageURLs: imageURLs) { result in
                if case .failure(let error) = result {
                    ErrorHandler.shared.handle(error)
                }
                self.removeExerciseFromFirestore(dayName: dayName, exerciseId: exerciseId, dayIndex: dayIndex, exerciseIndex: exerciseIndex, infoViewModel: infoViewModel)
            }
        } else {
            self.removeExerciseFromFirestore(dayName: dayName, exerciseId: exerciseId, dayIndex: dayIndex, exerciseIndex: exerciseIndex, infoViewModel: infoViewModel)
        }
    }
    
    
    private func removeExerciseFromFirestore(dayName: String, exerciseId: UUID, dayIndex: Int, exerciseIndex: Int, infoViewModel: InfoViewModel) {
        guard let userId = Auth.auth().currentUser?.uid else {
            ErrorHandler.shared.handle(AppError.authenticationError)
            return
        }
        
        let workoutRef = db.collection("users").document(userId).collection("workouts").document(dayName)
        
        workoutRef.getDocument { document, error in
            if let error = error {
                ErrorHandler.shared.handle(error)
                return
            }
            
            guard let document = document, document.exists else {
                return
            }
            
            guard var exercises = document.data()?["exercises"] as? [[String: Any]] else {
                return
            }
            
            if let index = exercises.firstIndex(where: { $0["id"] as? String == exerciseId.uuidString }) {
                exercises.remove(at: index)
                
                workoutRef.updateData(["exercises": exercises]) { error in
                    if let error = error {
                        ErrorHandler.shared.handle(error)
                    } else {
                        DispatchQueue.main.async {
                            self.workoutDays[dayIndex].exercises.remove(at: exerciseIndex)
                            
                            if self.workoutDays[dayIndex].exercises.isEmpty {
                                self.removeDay(dayName: dayName, infoViewModel: infoViewModel)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func removeDay(dayName: String, infoViewModel: InfoViewModel) {
        guard let userId = Auth.auth().currentUser?.uid else {
            ErrorHandler.shared.handle(AppError.authenticationError)
            return
        }
        
        guard let dayIndex = workoutDays.firstIndex(where: { $0.dayName == dayName }) else { return }
        
        let dayToDelete = workoutDays[dayIndex]
        
        let allImageURLs = dayToDelete.exercises
            .compactMap { $0.imageURLs }
            .flatMap { $0 }
        
        let workoutRef = db.collection("users").document(userId).collection("workouts")
        let dayDocumentRef = workoutRef.document(dayToDelete.dayName)
        
        let deleteWorkoutDay = {
            let batch = self.db.batch()
            var updatedWorkoutDays = self.workoutDays
            
            updatedWorkoutDays.remove(at: dayIndex)
            
            for (index, day) in self.workoutDays.enumerated() {
                if day.order != index {
                    updatedWorkoutDays[index].order = index
                    batch.updateData(["order": index], forDocument: workoutRef.document(day.dayName))
                }
            }
            
            batch.deleteDocument(dayDocumentRef)
            
            batch.commit { error in
                if let error = error {
                    ErrorHandler.shared.handle(error)
                } else {
                    DispatchQueue.main.async {
                        self.workoutDays = updatedWorkoutDays
                    }
                }
            }
        }
        
        if !allImageURLs.isEmpty {
            infoViewModel.deleteExerciseImages(dayName: dayName, exerciseId: nil as UUID?, imageURLs: allImageURLs) { result in
                switch result {
                case .success:
                    deleteWorkoutDay()
                case .failure(let error):
                    ErrorHandler.shared.handle(error)
                }
            }
        } else {
            deleteWorkoutDay()
        }
    }
    
    
    
    // MARK: - UPDATE
    
    func updateExercise(dayName: String, exercise: Exercise) {
        guard let userId = Auth.auth().currentUser?.uid else {
            ErrorHandler.shared.handle(AppError.authenticationError)
            return
        }
        
        guard let dayIndex = workoutDays.firstIndex(where: { $0.dayName == dayName }) else { return }
        guard let exerciseIndex = workoutDays[dayIndex].exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
        
        let workoutRef = db.collection("users").document(userId).collection("workouts").document(dayName)
        
        workoutRef.getDocument { document, error in
            if let error = error {
                ErrorHandler.shared.handle(error)
                return
            }
            
            guard let document = document, document.exists else { return }
            guard var exercises = document.data()?["exercises"] as? [[String: Any]] else { return }
            
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
                        ErrorHandler.shared.handle(error)
                    } else {
                        DispatchQueue.main.async {
                            self.workoutDays[dayIndex].exercises[exerciseIndex] = exercise
                        }
                    }
                }
            }
        }
    }
    
    
    
    // MARK: - LOAD
    
    func loadWorkoutDaysFromFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else {
            ErrorHandler.shared.handle(AppError.authenticationError)
            return
        }
        
        db.collection("users").document(userId).collection("workouts").order(by: "order").getDocuments { snapshot, error in
            if let error = error {
                ErrorHandler.shared.handle(error)
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            var fetchedWorkoutDays: [WorkoutDay] = []
            
            for document in documents {
                let data = document.data()
                
                guard let dayName = data["dayName"] as? String,
                      let exercisesData = data["exercises"] as? [[String: Any]],
                      let order = data["order"] as? Int else {
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
                        continue
                    }
                    
                    let imageURLs = exerciseData["imageURLs"] as? [String] ?? []
                    exercises.append(Exercise(id: uuid, name: name, sets: sets, reps: reps, weight: weight, info: info, imageURLs: imageURLs))
                }
                
                fetchedWorkoutDays.append(WorkoutDay(dayName: dayName, exercises: exercises, order: order))
            }
            
            DispatchQueue.main.async {
                self.workoutDays = fetchedWorkoutDays.sorted(by: { $0.order < $1.order })
            }
        }
    }
    
    
    
    // MARK: - SAVE
    
    
    private func saveWorkoutDayToFirestore(_ workoutDay: WorkoutDay) {
        guard let userId = Auth.auth().currentUser?.uid else {
            ErrorHandler.shared.handle(AppError.authenticationError)
            return
        }
        
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
                ErrorHandler.shared.handle(error)
            }
        }
    }
    
    
    
    // MARK: - Reordering
    
    func moveExercise(dayName: String, fromIndex: Int, directionUp: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else {
            ErrorHandler.shared.handle(AppError.authenticationError)
            return
        }
        
        guard let dayIndex = workoutDays.firstIndex(where: { $0.dayName == dayName }) else { return }
        
        let targetIndex = directionUp ? fromIndex - 1 : fromIndex + 1
        
        guard fromIndex >= 0, targetIndex >= 0, targetIndex < workoutDays[dayIndex].exercises.count else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            workoutDays[dayIndex].exercises.swapAt(fromIndex, targetIndex)
        }
        
        let workoutRef = db.collection("users").document(userId).collection("workouts").document(dayName)
        
        workoutRef.getDocument { document, error in
            if let error = error {
                ErrorHandler.shared.handle(error)
                return
            }
            
            guard let document = document, document.exists else { return }
            
            if var exercises = document.data()?["exercises"] as? [[String: Any]] {
                exercises.swapAt(fromIndex, targetIndex)
                
                workoutRef.updateData(["exercises": exercises]) { error in
                    if let error = error {
                        ErrorHandler.shared.handle(error)
                    }
                }
            }
        }
    }
    
    func moveDay(fromIndex: Int, directionLeft: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else {
            ErrorHandler.shared.handle(AppError.authenticationError)
            return
        }
        
        let toIndex = directionLeft ? fromIndex - 1 : fromIndex + 1
        
        guard fromIndex >= 0, toIndex >= 0, toIndex < workoutDays.count else { return }
        
        withAnimation(.easeInOut(duration: 0.3)) {
            workoutDays.swapAt(fromIndex, toIndex)
        }
        
        let workoutRef = db.collection("users").document(userId).collection("workouts")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            for (index, day) in self.workoutDays.enumerated() {
                self.workoutDays[index].order = index
                
                workoutRef.document(day.dayName).updateData(["order": index]) { error in
                    if let error = error {
                        ErrorHandler.shared.handle(error)
                    }
                }
            }
        }
    }
    
    func saveWorkoutDaysOrder() {
        guard let userId = Auth.auth().currentUser?.uid else {
            ErrorHandler.shared.handle(AppError.authenticationError)
            return
        }
        
        let workoutRef = db.collection("users").document(userId).collection("workouts")
        var batch = db.batch()
        var hasChanges = false
        
        var updatedWorkoutDays = workoutDays
        
        for (index, day) in updatedWorkoutDays.enumerated() {
            if day.order != index {
                hasChanges = true
                updatedWorkoutDays[index].order = index
                let docRef = workoutRef.document(day.dayName)
                batch.updateData(["order": index], forDocument: docRef)
            }
        }
        
        if hasChanges {
            batch.commit { error in
                if let error = error {
                    ErrorHandler.shared.handle(error)
                } else {
                    self.workoutDays = updatedWorkoutDays
                }
            }
        }
    }
    
    
    
    // MARK: - Hydration Management
    
    func loadHydrationData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            ErrorHandler.shared.handle(AppError.authenticationError)
            return
        }
        
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                ErrorHandler.shared.handle(error)
                return
            }
            
            guard let document = document, document.exists,
                  let hydrationData = document.data()?["hydration"] as? [String: Any] else {
                return
            }
            
            DispatchQueue.main.async {
                self.hydrationData.drinks = hydrationData["drinks"] as? [Double] ?? []
                self.hydrationData.glassVolume = hydrationData["glassVolume"] as? Double ?? 250.0
                self.hydrationData.dailyLimit = hydrationData["dailyLimit"] as? Double ?? 2000.0
            }
        }
    }
    
    func saveHydrationData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            ErrorHandler.shared.handle(AppError.authenticationError)
            return
        }

        let hydrationDict: [String: Any] = [
            "drinks": hydrationData.drinks,
            "glassVolume": hydrationData.glassVolume,
            "dailyLimit": hydrationData.dailyLimit
        ]
        
        db.collection("users").document(userId).setData(["hydration": hydrationDict], merge: true) { error in
            if let error = error {
                ErrorHandler.shared.handle(error)
            }
        }
    }
    
    
    
    // MARK: - Image Handling
    
    func uploadExerciseImage(dayName: String, exerciseId: UUID, imageData: Data?, infoViewModel: InfoViewModel, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            ErrorHandler.shared.handle(AppError.authenticationError)
            completion(.failure(AppError.authenticationError))
            return
        }
        
        guard let imageData = imageData, !imageData.isEmpty else {
            let error = AppError.invalidInput(fieldName: "Image data")
            ErrorHandler.shared.handle(error)
            completion(.failure(error))
            return
        }
        
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("exerciseImages/\(userId)/\(UUID().uuidString).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(imageData, metadata: metadata) { _, error in
            if let error = error {
                ErrorHandler.shared.handle(error)
                completion(.failure(error))
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    ErrorHandler.shared.handle(error)
                    completion(.failure(error))
                    return
                }
                
                guard let url = url else {
                    let error = AppError.databaseError
                    ErrorHandler.shared.handle(error)
                    completion(.failure(error))
                    return
                }
                
                self.updateExerciseImage(dayName: dayName, exerciseId: exerciseId, imageURL: url.absoluteString)
                
                completion(.success(url.absoluteString))
            }
        }
    }
    
    
    func updateExerciseImage(dayName: String, exerciseId: UUID, imageURL: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            ErrorHandler.shared.handle(AppError.authenticationError)
            return
        }
        
        guard let dayIndex = workoutDays.firstIndex(where: { $0.dayName == dayName }) else { return }
        
        guard let exerciseIndex = workoutDays[dayIndex].exercises.firstIndex(where: { $0.id == exerciseId }) else { return }
        
        DispatchQueue.main.async {
            if self.workoutDays[dayIndex].exercises[exerciseIndex].imageURLs == nil {
                self.workoutDays[dayIndex].exercises[exerciseIndex].imageURLs = []
            }
            self.workoutDays[dayIndex].exercises[exerciseIndex].imageURLs?.append(imageURL)
        }
        
        let exerciseRef = db.collection("users").document(userId).collection("workouts").document(dayName)
        
        exerciseRef.getDocument { document, error in
            if let error = error {
                ErrorHandler.shared.handle(error)
                return
            }
            
            guard let document = document, document.exists else { return }
            
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
                            ErrorHandler.shared.handle(error)
                            
                            DispatchQueue.main.async {
                                self.workoutDays[dayIndex].exercises[exerciseIndex].imageURLs?.removeAll(where: { $0 == imageURL })
                            }
                        }
                    }
                }
            }
        }
    }
}
