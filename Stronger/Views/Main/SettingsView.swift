//
//  SettingsView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 22/10/2024.
//

import SwiftUI
import Firebase

struct SettingsView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    @StateObject private var viewModel = SettingsViewModel()
    
    @State private var showDeleteAccountAlert = false
    @State private var isTransitioning = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Main functions")
                .font(.headline)
                .foregroundColor(Color.theme.text.opacity(0.8))
            
            Button(action: {
                viewModel.toggleDarkMode()
            }) {
                HStack {
                    Text("Dark Mode")
                        .font(.headline)
                        .foregroundColor(Color.theme.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: 120)
                    
                    Toggle("", isOn: $viewModel.isDarkMode)
                        .labelsHidden()
                }
                .padding()
                .background(Color.theme.accent.opacity(0.15))
                .cornerRadius(12)
                .shadow(color: Color.theme.text.opacity(0.1), radius: 5, x: 0, y: 5)
            }
            
            TransparentButton(title: "Log out") {
                Task {
                    do {
                        try viewModel.signOut()
                        authViewModel.isUserLoggedIn = false
                    } catch {
                        print(error)
                    }
                }
            }
            
            TransparentButton(title: "Delete account") {
                showDeleteAccountAlert = true
            }
            .showConfirmationAlert(isPresented: $showDeleteAccountAlert) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        authViewModel.isUserLoggedIn = false
                    } catch {
                        print(error)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Email functions")
                    .font(.headline)
                    .foregroundColor(Color.theme.text.opacity(0.8))
                
                TransparentButton(title: "Reset password") {
                    Task {
                        do {
                            try await viewModel.resetPassword()
                        } catch {
                            print(error)
                        }
                    }
                }
                
                TransparentButton(title: "Update password") {
                    Task {
                        do {
                            try await viewModel.updatePassword()
                        } catch {
                            print(error)
                        }
                    }
                }
                
                TransparentButton(title: "Update email") {
                    Task {
                        do {
                            try await viewModel.updateEmail()
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .padding(.top, 66)
        .applyGradientBackground()
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
