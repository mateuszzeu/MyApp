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
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Main functions")
                        .font(.headline)
                        .foregroundColor(Color.theme.text.opacity(0.8))
                    
                    Button(action: {
                        isDarkMode.toggle()
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
                            }
                    }) {
                        HStack {
                            Text("Dark Mode")
                                .font(.headline)
                                .foregroundColor(Color.theme.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .offset(x: 120)
                            

                            Toggle("", isOn: $isDarkMode)
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
                                showSignInView = true
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
                                showSignInView = true
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
                                    print("PASSWORD RESET")
                                } catch {
                                    print(error)
                                }
                            }
                        }
                        
                        TransparentButton(title: "Update password") {
                            Task {
                                do {
                                    try await viewModel.updatePassword()
                                    print("PASSWORD UPDATED")
                                } catch {
                                    print(error)
                                }
                            }
                        }
                        
                        TransparentButton(title: "Update email") {
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
                .padding()
            }
            .scrollContentBackground(.hidden)
            .applyGradientBackground()
            .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Settings")
                            .font(.system(size: 22))
                            .fontWeight(.bold)
                    }
                }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(showSignInView: .constant(false))
    }
}
