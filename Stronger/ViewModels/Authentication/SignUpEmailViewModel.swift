//
//  SignUpEmailViewModel.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 25/10/2024.
//

import Foundation

@MainActor
final class SignUpEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""
    @Published var showErrorMessage = false
    
    func isValidData() -> Bool {
        guard ValidationHelper.isValidEmail(email) else {
            errorMessage = "Invalid email format"
            return false
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return false
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return false
        }
        
        return true
    }
    
    func signUp() async throws {
        try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
}
