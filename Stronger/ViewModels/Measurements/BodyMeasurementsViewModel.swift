//
//  BodyMeasurementsViewModel.swift
//  Stronger
//
//  Created by Liza on 03/02/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class BodyMeasurementsViewModel: ObservableObject {
    
    @Published var measurements: [BodyMeasurements] = []
    @Published var chest: String = ""
    @Published var shoulders: String = ""
    @Published var waist: String = ""
    @Published var hips: String = ""
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func fetchMeasurements() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users")
            .document(userId)
            .collection("dailyMeasurements")
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching body measurements: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.measurements = documents.compactMap { document in
                    let data = document.data()
                    
                    
                    if data["chest"] == nil && data["shoulders"] == nil && data["waist"] == nil && data["hips"] == nil {
                        return nil
                    }
                    
                    return BodyMeasurements(dictionary: data)
                }
            }
    }
    
    func saveMeasurements(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        guard let chestVal = Double(chest),
              let shouldersVal = Double(shoulders),
              let waistVal = Double(waist),
              let hipsVal = Double(hips) else {
            completion(.failure(NSError(domain: "Invalid input", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid numeric values"])))
            return
        }
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let documentId = dateFormatter.string(from: currentDate)
        
        let newMeasurements = BodyMeasurements(
            id: UUID(),
            date: currentDate,
            chest: chestVal,
            shoulders: shouldersVal,
            waist: waistVal,
            hips: hipsVal
        )
        
        let docRef = db.collection("users")
            .document(userId)
            .collection("dailyMeasurements")
            .document(documentId)
        
        docRef.setData(newMeasurements.dictionary, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func clearMeasurementsFields() {
        chest = ""
        shoulders = ""
        waist = ""
        hips = ""
    }
    
    func stopListening() {
        listener?.remove()
    }
}
