//
//  AuthenticationView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 22/10/2024.
//
import SwiftUI

struct AuthenticationView: View {
    @Binding var showSignInView: Bool
    @State private var showContent = false
    @StateObject private var viewModel = SignInEmailViewModel()

    var body: some View {
        ZStack {
            if !showContent {
                LogoAnimationView {
                    withAnimation(.easeInOut(duration: 3.0)) {
                        showContent = true
                    }
                }
                .transition(.opacity)
            }

            if showContent {
                VStack(spacing: 20) {
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height * 0.15)

                    VStack(spacing: 15) {
                        TextField("Email...", text: $viewModel.email)
                            .padding()
                            .applyTransparentBackground()
                        
                        SecureField("Password...", text: $viewModel.password)
                            .padding()
                            .applyTransparentBackground()

                        if viewModel.showErrorMessage {
                            Text(viewModel.errorMessage)
                                //.foregroundColor(.red)
                                .foregroundColor(Color.theme.accent)
                                .font(.footnote)
                                .padding(.top, 10)
                        }

                        Button {
                            Task {
                                viewModel.showErrorMessage = false
                                viewModel.errorMessage = ""

                                do {
                                    try await viewModel.signInUser()

                                    if !viewModel.showErrorMessage {
                                        showSignInView = false
                                    }
                                } catch {
                                    print("Login error: \(error.localizedDescription)")
                                    viewModel.errorMessage = "Invalid login credentials"
                                    viewModel.showErrorMessage = true
                                }
                            }
                        } label: {
                            Text("Sign In")
                                .font(.headline)
                                //.foregroundColor(.white)
                                .foregroundColor(Color.theme.text)
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
                                //.background(Color.blue)
                                .background(Color.theme.primary)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)

                    NavigationLink {
                        SignUpEmailView(showSignInView: $showSignInView)
                    } label: {
                        Text("Register")
                            .font(.headline)
                            //.foregroundColor(.white)
                            .foregroundColor(Color.theme.text)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            //.background(Color.green)
                            .background(Color.theme.accent)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .transition(.opacity)
            }
        }
        .applyGradientBackground()
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(false))
    }
}
