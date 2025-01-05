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
                            .background(Color.gray.opacity(0.4))
                            .cornerRadius(10)

                        SecureField("Password...", text: $viewModel.password)
                            .padding()
                            .background(Color.gray.opacity(0.4))
                            .cornerRadius(10)

                        if viewModel.showErrorMessage {
                            Text(viewModel.errorMessage)
                                .foregroundColor(.red)
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
                                .foregroundColor(.white)
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)

                    NavigationLink {
                        SignUpEmailView(showSignInView: $showSignInView)
                    } label: {
                        Text("Register")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .transition(.opacity)
            }
        }
        .applyGradientBackground()
    }
}

#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(false))
    }
}
