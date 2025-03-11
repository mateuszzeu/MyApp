//
//  InfoViewModel.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 23/10/2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class InfoViewModel: ObservableObject {
    @Published var selectedImagesForDeletion: Set<String> = []
    
    private var db = Firestore.firestore()

    func uploadExerciseImage(dayName: String, exerciseId: UUID, imageData: Data?, workoutViewModel: WorkoutViewModel, completion: @escaping (Result<String, Error>) -> Void) {
            guard let userId = Auth.auth().currentUser?.uid else {
                let error = AppError.authenticationError
                ErrorHandler.shared.handle(error)
                completion(.failure(error))
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
                    
                    workoutViewModel.updateExerciseImage(dayName: dayName, exerciseId: exerciseId, imageURL: url.absoluteString)
                    completion(.success(url.absoluteString))
                }
            }
        }


    func deleteExerciseImages(dayName: String?, exerciseId: UUID?, imageURLs: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            let error = AppError.authenticationError
            ErrorHandler.shared.handle(error)
            completion(.failure(error))
            return
        }

        guard !imageURLs.isEmpty else {
            print("⚠️ No images to delete.")
            completion(.success(()))
            return
        }

        let storageRef = Storage.storage().reference()
        let dispatchGroup = DispatchGroup()
        var errors: [Error] = []
        var successfullyDeletedImages: [String] = []

        for imageURL in imageURLs {
            guard let url = URL(string: imageURL) else { continue }

            let lastPathComponent = url.lastPathComponent
            let imageRef = storageRef.child("exerciseImages/\(userId)/\(lastPathComponent)")

            dispatchGroup.enter()
            imageRef.delete { error in
                if let error = error {
                    errors.append(error)
                    ErrorHandler.shared.handle(error)
                } else {
                    successfullyDeletedImages.append(imageURL)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            if let dayName = dayName, let exerciseId = exerciseId, !successfullyDeletedImages.isEmpty {
                self.removeImageURLsFromFirestore(dayName: dayName, exerciseId: exerciseId, imageURLs: successfullyDeletedImages) { result in
                    completion(result)
                }
            } else {
                let finalError = errors.isEmpty ? nil : AppError.databaseError
                if let finalError = finalError {
                    ErrorHandler.shared.handle(finalError)
                    completion(.failure(finalError))
                } else {
                    completion(.success(()))
                }
            }
        }
    }


    private func removeImageURLsFromFirestore(dayName: String, exerciseId: UUID, imageURLs: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            let error = AppError.authenticationError
            ErrorHandler.shared.handle(error)
            completion(.failure(error))
            return
        }

        let exerciseRef = db.collection("users").document(userId).collection("workouts").document(dayName)

        exerciseRef.getDocument { document, error in
            if let error = error {
                ErrorHandler.shared.handle(error)
                completion(.failure(error))
                return
            }
            guard let document = document, document.exists else {
                completion(.success(()))
                return
            }
            
            guard var exercises = document.data()?["exercises"] as? [[String: Any]] else {
                let error = AppError.databaseError
                ErrorHandler.shared.handle(error)
                completion(.failure(error))
                return
            }

            if let index = exercises.firstIndex(where: { $0["id"] as? String == exerciseId.uuidString }) {
                var updatedExercise = exercises[index]

                if var existingImageURLs = updatedExercise["imageURLs"] as? [String] {
                    existingImageURLs.removeAll { imageURLs.contains($0) }
                    updatedExercise["imageURLs"] = existingImageURLs
                }

                exercises[index] = updatedExercise

                exerciseRef.updateData(["exercises": exercises]) { error in
                    if let error = error {
                        ErrorHandler.shared.handle(error)
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            } else {
                completion(.success(()))
            }
        }
    }
    
    func toggleImageSelection(_ imageURL: String) {
        if selectedImagesForDeletion.contains(imageURL) {
            selectedImagesForDeletion.remove(imageURL)
        } else {
            selectedImagesForDeletion.insert(imageURL)
        }
    }

    func deleteSelectedImages(dayName: String, exerciseId: UUID, workoutViewModel: WorkoutViewModel, completion: @escaping (Result<[String], Error>) -> Void) {
        guard !selectedImagesForDeletion.isEmpty else {
            let error = AppError.invalidInput(fieldName: "No images selected for deletion")
            ErrorHandler.shared.handle(error)
            completion(.failure(error))
            return
        }

        let imagesToDelete = Array(selectedImagesForDeletion)

        deleteExerciseImages(dayName: dayName, exerciseId: exerciseId, imageURLs: imagesToDelete) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.selectedImagesForDeletion.removeAll()
                    completion(.success(imagesToDelete))
                    workoutViewModel.objectWillChange.send()

                case .failure(let error):
                    ErrorHandler.shared.handle(error)
                    completion(.failure(error))
                }
            }
        }
    }
}

