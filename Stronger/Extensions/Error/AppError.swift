//
//  AppError.swift
//  Stronger
//
//  Created by Liza on 21/02/2025.
//
import SwiftUI

enum AppError: LocalizedError {
    case invalidEmail
    case passwordTooShort
    case passwordsDoNotMatch
    case emptyField(fieldName: String)
    case invalidInput(fieldName: String)
    case authenticationError
    case networkError
    case databaseError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Invalid email address."
        case .passwordTooShort:
            return "Password must be at least 6 characters long."
        case .passwordsDoNotMatch:
            return "Passwords do not match."
        case .emptyField(let fieldName):
            return "\(fieldName) field cannot be empty."
        case .invalidInput(let fieldName):
            return "\(fieldName) must be a valid number."
        case .authenticationError:
            return "Login failed. Please check your credentials."
        case .networkError:
            return "No internet connection."
        case .databaseError:
            return "Database connection error."
        case .unknownError:
            return "An unexpected error occurred."
        }
    }
}


