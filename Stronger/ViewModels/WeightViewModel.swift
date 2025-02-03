//
//  WeightViewModel.swift
//  Stronger
//
//  Created by Liza on 03/02/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class WeightViewModel: ObservableObject {
    
    @Published var dailyWeights: [DailyWeight] = []
    @Published var weight: String = ""
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func fetchDailyWeights() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users")
            .document(userId)
            .collection("dailyMeasurements")
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                self.dailyWeights = documents.compactMap {
                    DailyWeight(dictionary: $0.data())
                }
            }
    }
    
    func saveWeight(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }

        guard let weightVal = Double(weight) else {
            completion(.failure(NSError(domain: "Invalid input", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid numeric value for weight"])))
            return
        }

        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let documentId = dateFormatter.string(from: currentDate)

        let newWeightEntry = DailyWeight(
            id: UUID(),
            date: currentDate,
            weight: weightVal
        )

        let docRef = db.collection("users")
            .document(userId)
            .collection("dailyMeasurements")
            .document(documentId)

        docRef.setData(newWeightEntry.dictionary, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func clearWeightField() {
        weight = ""
    }
    
    func stopListening() {
        listener?.remove()
    }
}

#Preview {
    let weightViewModel = WeightViewModel()
    
    weightViewModel.dailyWeights = [
        DailyWeight(date: Date(), weight: 70.5),
        DailyWeight(date: Date().addingTimeInterval(-86400), weight: 71.0)
    ]
    
    return WeightHistoryView(weightViewModel: weightViewModel)
}
