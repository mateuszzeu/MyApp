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
    
    func signInUser() async throws -> AuthDataResultModel {
        guard ValidationHelper.isValidEmail(email) else {
            errorMessage = "Invalid email format"
            showErrorMessage = true
            throw NSError(domain: "InvalidEmail", code: 1, userInfo: nil)
        }
        
        guard !password.isEmpty else {
            errorMessage = "Password cannot be empty"
            showErrorMessage = true
            throw NSError(domain: "EmptyPassword", code: 2, userInfo: nil)
        }
        
        do {
            let userData = try await AuthenticationManager.shared.signInUser(email: email, password: password)
            return userData
        } catch {
            print("Login error: \(error.localizedDescription)")
            errorMessage = "Invalid login credentials"
            showErrorMessage = true
            throw error
        }
    }
}
