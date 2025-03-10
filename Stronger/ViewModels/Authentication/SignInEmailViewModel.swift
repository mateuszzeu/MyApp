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

    func signInUser() async throws {
        guard !email.isEmpty else {
            ErrorHandler.shared.handle(AppError.emptyField(fieldName: "Email"))
            throw AppError.emptyField(fieldName: "Email")
        }
        
        guard ValidationHelper.isValidEmail(email) else {
            ErrorHandler.shared.handle(AppError.invalidEmail)
            throw AppError.invalidEmail
        }
        
        guard !password.isEmpty else {
            ErrorHandler.shared.handle(AppError.emptyField(fieldName: "Hasło"))
            throw AppError.emptyField(fieldName: "Hasło")
        }
        
        do {
            _ = try await AuthenticationManager.shared.signInUser(email: email, password: password)
        } catch {
            ErrorHandler.shared.handle(AppError.authenticationError)
            throw AppError.authenticationError
        }
    }
}
