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
    
    // MARK: - Dark Mode Handling
    @AppStorage("isDarkMode") var isDarkMode: Bool = false {
        didSet {
            SettingsViewModel.applyInterfaceStyle(isDarkMode)
        }
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
    
    // Applies the selected interface style (light/dark mode) globally
    static func applyInterfaceStyle(_ isDarkMode: Bool) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return }
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }
    
    // Loads and applies the previously saved dark mode preference
    static func applySavedTheme() {
        let savedTheme = UserDefaults.standard.bool(forKey: "isDarkMode")
        applyInterfaceStyle(savedTheme)
    }
    
    // MARK: - Authentication Handling
    
    func signOut() throws {
        do {
            try AuthenticationManager.shared.signOut()
        } catch {
            throw AppError.authenticationError
        }
    }
    
    func resetPassword() async throws {
        do {
            let authUser = try await AuthenticationManager.shared.getAuthenticatedUser()
            guard let email = authUser.email else {
                throw AppError.emptyField(fieldName: "Email")
            }
            try await AuthenticationManager.shared.resetPassword(email: email)
        } catch {
            throw AppError.authenticationError
        }
    }
    
    func updateEmail(newEmail: String) async throws {
        do {
            try await AuthenticationManager.shared.updateEmail(email: newEmail)
        } catch {
            throw AppError.authenticationError
        }
    }
    
    func updatePassword(newPassword: String) async throws {
        do {
            try await AuthenticationManager.shared.updatePassword(password: newPassword)
        } catch {
            throw AppError.authenticationError
        }
    }
    
    func deleteAccount() async throws {
        do {
            try await deleteUserData()
            try await AuthenticationManager.shared.delete()
        } catch {
            throw AppError.databaseError
        }
    }
    
    // MARK: - Firestore Handling
    
    private func deleteUserData() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AppError.authenticationError
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
