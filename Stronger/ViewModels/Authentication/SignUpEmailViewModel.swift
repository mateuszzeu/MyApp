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

    func signUp() async throws {
        guard !email.isEmpty else {
            ErrorHandler.shared.handle(AppError.emptyField(fieldName: "Email"))
            throw AppError.emptyField(fieldName: "Email")
        }
        
        guard ValidationHelper.isValidEmail(email) else {
            ErrorHandler.shared.handle(AppError.invalidEmail)
            throw AppError.invalidEmail
        }
        
        guard !password.isEmpty else {
            ErrorHandler.shared.handle(AppError.emptyField(fieldName: "Password"))
            throw AppError.emptyField(fieldName: "Password")
        }
        
        guard password.count >= 6 else {
            ErrorHandler.shared.handle(AppError.passwordTooShort)
            throw AppError.passwordTooShort
        }
        
        guard password == confirmPassword else {
            ErrorHandler.shared.handle(AppError.passwordsDoNotMatch)
            throw AppError.passwordsDoNotMatch
        }
        
        do {
            try await AuthenticationManager.shared.createUser(email: email, password: password)
        } catch {
            ErrorHandler.shared.handle(AppError.authenticationError)
            throw AppError.authenticationError
        }
    }
}

