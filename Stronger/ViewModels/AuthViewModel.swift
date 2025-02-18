//
//  AuthViewModel.swift
//  Stronger
//
//  Created by Liza on 17/02/2025.
//

import SwiftUI
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var isUserLoggedIn: Bool = Auth.auth().currentUser != nil

    init() {
        checkAuthenticationStatus()
    }

    func checkAuthenticationStatus() {
        isUserLoggedIn = Auth.auth().currentUser != nil
    }

    func signOut() throws {
        try Auth.auth().signOut()
        isUserLoggedIn = false
    }
}
