//
//  SignInEmailViewModel.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 22/10/2024.
//
import SwiftUI

@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var showErrorMessage = false
    
    func signInUser() async throws {
        guard ValidationHelper.isValidEmail(email) else {
            errorMessage = "Invalid email format"
            showErrorMessage = true
            return
        }
        
        guard !password.isEmpty else {
            errorMessage = "Password cannot be empty"
            showErrorMessage = true
            return
        }
        
        do {
            try await AuthenticationManager.shared.signInUser(email: email, password: password)
        } catch {
            print("Login error: \(error.localizedDescription)")
            errorMessage = "Invalid login credentials"
            showErrorMessage = true
        }
    }
}
