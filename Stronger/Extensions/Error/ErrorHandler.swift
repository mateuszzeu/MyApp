//
//  ErrorHandler.swift
//  Stronger
//
//  Created by Liza on 21/02/2025.
//

import SwiftUI

final class ErrorHandler: ObservableObject {
    static let shared = ErrorHandler()
    
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    func handle(_ error: Error) {
        if let appError = error as? AppError {
            errorMessage = appError.localizedDescription
        } else {
            errorMessage = "Unknown error: \(error.localizedDescription)"
        }
        showError = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showError = false
            self.errorMessage = nil
        }
    }
}






