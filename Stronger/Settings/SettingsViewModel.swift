//
//  SettingsViewModel.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 22/10/2024.
//
import FirebaseAuth
import FirebaseFirestore
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        let email = "Lizuneczka@example.com"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "dupa12341234"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func deleteAccount() async throws {
        do {
            try await deleteUserData()
            
            try await AuthenticationManager.shared.delete()
        } catch {
            print("Błąd podczas usuwania danych lub konta: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func deleteUserData() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw URLError(.badServerResponse)
        }
        
        let db = Firestore.firestore()
        let userWorkoutsRef = db.collection("users").document(userId).collection("workouts")
        
        let documents = try await userWorkoutsRef.getDocuments()
        
        for document in documents.documents {
            try await document.reference.delete()
        }
        
        try await db.collection("users").document(userId).delete()
    }
}

