//
//  SettingsViewModel.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 22/10/2024.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = false {
        didSet {
            SettingsViewModel.applyInterfaceStyle(isDarkMode)
        }
    }
    
    static func applyInterfaceStyle(_ isDarkMode: Bool) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }
    
    static func applySavedTheme() {
        let savedTheme = UserDefaults.standard.bool(forKey: "isDarkMode")
        applyInterfaceStyle(savedTheme)
    }
    
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let authUser = try await AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        let email = "Testing@example.com"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "H@sl01234567"
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
