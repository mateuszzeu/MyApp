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
            } else {
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("❌ Error getting image URL: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else if let url = url {
                        print("✅ Image uploaded successfully: \(url.absoluteString)")
                        workoutViewModel.updateExerciseImage(dayName: dayName, exerciseId: exerciseId, imageURL: url.absoluteString)
                        completion(.success(url.absoluteString))
                    }
                }
            }
        }
    }


    func deleteExerciseImages(dayName: String?, exerciseId: UUID?, imageURLs: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "User not found."])))
            return
        }

        guard !imageURLs.isEmpty else {
            print("⚠️ No images to delete.")
            completion(.success(()))
            return
        }

        let storageRef = Storage.storage().reference()
        let dispatchGroup = DispatchGroup()
        var errors: [String: Error] = [:]
        var successfullyDeletedImages: [String] = []

        for imageURL in imageURLs {
            guard let url = URL(string: imageURL) else {
                print("❌ Skipping invalid image URL: \(imageURL)")
                continue
            }

            let lastPathComponent = url.lastPathComponent
            let imageRef = storageRef.child("exerciseImages/\(userId)/\(lastPathComponent)")

            dispatchGroup.enter()
            imageRef.delete { error in
                if let error = error {
                    errors[imageURL] = error
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
                completion(errors.isEmpty ? .success(()) : .failure(NSError(domain: "", code: -4, userInfo: [NSLocalizedDescriptionKey: "Some images could not be deleted."])))
            }
        }
    }


    private func removeImageURLsFromFirestore(dayName: String, exerciseId: UUID, imageURLs: [String], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])))
            return
        }

        let exerciseRef = db.collection("users").document(userId).collection("workouts").document(dayName)

        exerciseRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let document = document, document.exists else {
                completion(.success(()))
                return
            }
            guard var exercises = document.data()?["exercises"] as? [[String: Any]] else {
                completion(.failure(NSError(domain: "", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid exercises data structure."])))
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

    func deleteSelectedImages(dayName: String, exerciseId: UUID, workoutViewModel: WorkoutViewModel, exercise: Exercise) {
        guard !selectedImagesForDeletion.isEmpty else { return }
        
        var updatedExercise = exercise
        
        deleteExerciseImages(dayName: dayName, exerciseId: exerciseId, imageURLs: Array(selectedImagesForDeletion)) { result in
            switch result {
            case .success:
                updatedExercise.imageURLs?.removeAll { self.selectedImagesForDeletion.contains($0) }
                self.selectedImagesForDeletion.removeAll()
                
                workoutViewModel.updateExercise(dayName: dayName, exercise: updatedExercise)
                
            case .failure(let error):
                print("❌ Error deleting images: \(error.localizedDescription)")
            }
        }
    }
}

