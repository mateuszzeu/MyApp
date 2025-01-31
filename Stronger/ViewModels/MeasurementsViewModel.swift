//
//  MeasurementsViewModel.swift
//  Stronger
//
//  Created by Liza on 22/01/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class MeasurementsViewModel: ObservableObject {
    @Published var dailyMeasurements: [DailyMeasurement] = []
    @Published var weight: String = ""
    @Published var protein: String = ""
    @Published var carbs: String = ""
    @Published var fat: String = ""
    @Published var calories: String = ""
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func fetchDailyMeasurements() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users")
            .document(userId)
            .collection("dailyMeasurements")
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching daily measurements: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self.dailyMeasurements = documents.compactMap {
                    DailyMeasurement(dictionary: $0.data())
                }
            }
    }
    
    func commitMeasurement(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(
                domain: "No user",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "User not logged in"]
            )))
            return
        }
        
        guard let weightVal = Double(weight),
              let proteinVal = Double(protein),
              let carbsVal = Double(carbs),
              let fatVal = Double(fat),
              let caloriesVal = Double(calories) else {
            
            completion(.failure(NSError(
                domain: "Invalid input",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Invalid numeric values"]
            )))
            return
        }
        
        let newMeasurement = DailyMeasurement(
            date: Date(),
            weight: weightVal,
            macros: DailyMeasurement.Macros(
                protein: proteinVal,
                carbs: carbsVal,
                fat: fatVal,
                calories: caloriesVal
            )
        )
        
        let docRef = db.collection("users")
            .document(userId)
            .collection("dailyMeasurements")
            .document(newMeasurement.id.uuidString)
        
        docRef.setData(newMeasurement.dictionary) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func clearFields() {
        weight = ""
        protein = ""
        carbs = ""
        fat = ""
        calories = ""
    }
    
    func stopListening() {
        listener?.remove()
    }
}
