//
//  MacrosViewModel.swift
//  Stronger
//
//  Created by Liza on 03/02/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

@MainActor
class MacrosViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var dailyMacros: [DailyMacros] = []
    @Published var protein: String = ""
    @Published var carbs: String = ""
    @Published var fat: String = ""
    @Published var calories: String = ""
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // MARK: - Firestore Methods
    
    func fetchDailyMacros() {
        guard let userId = Auth.auth().currentUser?.uid else {
            ErrorHandler.shared.handle(AppError.authenticationError)
            return
        }
        
        db.collection("users")
            .document(userId)
            .collection("dailyMeasurements")
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    ErrorHandler.shared.handle(error)
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.dailyMacros = documents.compactMap { document in
                    let data = document.data()
                    
                    if data["protein"] == nil && data["carbs"] == nil && data["fat"] == nil && data["calories"] == nil {
                        return nil
                    }
                    
                    return DailyMacros(dictionary: data)
                }
            }
    }
    
    func saveMacros(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            let error = AppError.authenticationError
            ErrorHandler.shared.handle(error)
            completion(.failure(error))
            return
        }
        
        guard let proteinVal = Double(protein),
              let carbsVal = Double(carbs),
              let fatVal = Double(fat),
              let caloriesVal = Double(calories) else {
            let error = AppError.invalidInput(fieldName: "Macros")
            ErrorHandler.shared.handle(error)
            completion(.failure(error))
            return
        }
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let documentId = dateFormatter.string(from: currentDate)
        
        let newMacrosEntry = DailyMacros(
            id: UUID(),
            date: currentDate,
            protein: proteinVal,
            carbs: carbsVal,
            fat: fatVal,
            calories: caloriesVal
        )
        
        let docRef = db.collection("users")
            .document(userId)
            .collection("dailyMeasurements")
            .document(documentId)
        
        docRef.setData(newMacrosEntry.dictionary, merge: true) { error in
            if let error = error {
                ErrorHandler.shared.handle(error)
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Helpers
    
    func clearMacrosFields() {
        protein = ""
        carbs = ""
        fat = ""
        calories = ""
    }
    
    func stopListening() {
        listener?.remove()
    }
}

#Preview {
    let macrosViewModel = MacrosViewModel()
    
    macrosViewModel.dailyMacros = [
        DailyMacros(date: Date(), protein: 150, carbs: 200, fat: 50, calories: 2500),
        DailyMacros(date: Date().addingTimeInterval(-86400), protein: 140, carbs: 210, fat: 55, calories: 2600)
    ]
    
    return MacrosHistoryView(macrosViewModel: macrosViewModel)
}
