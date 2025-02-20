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
    
    func fetchCompletedWorkouts() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let ref = db.collection("users")
            .document(userId)
            .collection("completedWorkouts")
            .order(by: "date", descending: true)
        
        listener = ref.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching completed workouts: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            var fetched: [CompletedWorkout] = []
            for doc in documents {
                let data = doc.data()
                if let cw = CompletedWorkout(dictionary: data) {
                    fetched.append(cw)
                }
            }
            
            self.completedWorkouts = fetched
        }
    }
    
    func stopListening() {
        listener?.remove()
    }
    
    func saveDayToHistory(day: WorkoutDay) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
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
        
        try await docRef.setData(newCompleted.dictionary)
    }
}
