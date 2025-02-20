//
//  AuthenticationManager.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 22/10/2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    let isApproved: Bool
    
    init(user: User, isApproved: Bool) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isApproved = isApproved
    }
}

final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() { }
    
    func getAuthenticatedUser() async throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }

        let userRef = Firestore.firestore().collection("users").document(user.uid)
        let snapshot = try await userRef.getDocument()
        let isApproved = snapshot.data()?["isApproved"] as? Bool ?? false

        return AuthDataResultModel(user: user, isApproved: isApproved)
    }

    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let userId = authDataResult.user.uid
        let userRef = Firestore.firestore().collection("users").document(userId)

        let userData: [String: Any] = [
            "email": email,
            "isApproved": false
        ]

        try await userRef.setData(userData)
        return AuthDataResultModel(user: authDataResult.user, isApproved: false)
    }

    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        let userId = authDataResult.user.uid
        let userRef = Firestore.firestore().collection("users").document(userId)
        let snapshot = try await userRef.getDocument()
        let isApproved = snapshot.data()?["isApproved"] as? Bool ?? false

        let userModel = AuthDataResultModel(user: authDataResult.user, isApproved: isApproved)

        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        
        return userModel
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updateEmail(to: email)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
    }
    
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        try await user.delete()
    }
}
