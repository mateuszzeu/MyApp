//
//  StatsViewModel.swift
//  Stronger
//
//  Created by Liza on 14/01/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class StatsViewModel: ObservableObject {
    @Published var completedWorkouts: [CompletedWorkout] = []
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // MARK: - Firestore Methods
    
    func fetchCompletedWorkouts() {
        guard let userId = Auth.auth().currentUser?.uid else {
            ErrorHandler.shared.handle(AppError.authenticationError)
            return
        }
        
        let ref = db.collection("users")
            .document(userId)
            .collection("completedWorkouts")
            .order(by: "date", descending: true)
        
        listener = ref.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                ErrorHandler.shared.handle(AppError.databaseError)
                print("Error fetching completed workouts: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            self.completedWorkouts = documents.compactMap { doc in
                CompletedWorkout(dictionary: doc.data())
            }
        }
    }
    
    func saveDayToHistory(day: WorkoutDay) async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AppError.authenticationError
        }
        
        let newCompleted = CompletedWorkout(
            date: Date(),
            workoutDayName: day.dayName,
            exercises: day.exercises,
            notes: nil
        )
        
        let docRef = db.collection("users")
            .document(userId)
            .collection("completedWorkouts")
            .document(newCompleted.id.uuidString)
        
        do {
            try await docRef.setData(newCompleted.dictionary)
        } catch {
            throw AppError.databaseError
        }
    }
    
    func stopListening() {
        listener?.remove()
    }
}
