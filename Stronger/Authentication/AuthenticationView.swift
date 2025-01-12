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
                                .foregroundColor(Color.theme.text)
                                .frame(height: 55)
                                .frame(maxWidth: .infinity)
                                .background(Color.theme.primary)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            print("Sign in with Apple tapped")
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                    .foregroundColor(.white)
                                Text("Sign in with Apple")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            print("Sign in with Google tapped")
                        }) {
                            HStack {
                                Image("google")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                Text("Sign in with Google")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    NavigationLink {
                        SignUpEmailView(showSignInView: $showSignInView)
                    } label: {
                        Text("Register")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
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
    }
}

#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(false))
    }
}
