//
//  SettingsView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 22/10/2024.
//
import SwiftUI
import Firebase

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button(role: .destructive) {
                showDeleteAccountAlert = true
            } label: {
                Text("Delete account")
            }
            .showConfirmationAlert(isPresented: $showDeleteAccountAlert) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            }
            
            Section(header: Text("Email functions")) {
                Button("Reset password") {
                    Task {
                        do {
                            try await viewModel.resetPassword()
                            print("PASSWORD RESET")
                        } catch {
                            print(error)
                        }
                    }
                }
                
                Button("Update password") {
                    Task {
                        do {
                            try await viewModel.updatePassword()
                            print("PASSWORD UPDATED")
                        } catch {
                            print(error)
                        }
                    }
                }
                
                Button("Update email") {
                    Task {
                        do {
                            try await viewModel.updateEmail()
                            print("EMAIL UPDATED")
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .applyGradientBackground()
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(showSignInView: .constant(false))
    }
}


