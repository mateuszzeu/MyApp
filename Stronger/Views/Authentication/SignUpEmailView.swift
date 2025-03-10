//
//  SignUpEmailView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 25/10/2024.
//

import SwiftUI

struct SignUpEmailView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject private var viewModel = SignUpEmailViewModel()
    @Binding var showSignInView: Bool
    @State private var showSuccessMessage = false
    @State private var isNavigatedToSignInView = false
    
    var body: some View {
        VStack {
            CustomTextField(placeholder: "Email...", text: $viewModel.email)
            
            CustomTextField(placeholder: "Password...", text: $viewModel.password, isSecure: true)
                .textContentType(.newPassword)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            CustomTextField(placeholder: "Confirm Password...", text: $viewModel.confirmPassword, isSecure: true)
                .textContentType(.newPassword)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        showSuccessMessage = true
                    } catch {
                        ErrorHandler.shared.handle(error)
                    }
                }
            } label: {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(Color.theme.text)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.theme.primary)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showSuccessMessage) {
            SuccessSheetView {
                isNavigatedToSignInView = true
                showSuccessMessage = false
            }
        }
        .navigationDestination(isPresented: $isNavigatedToSignInView) {
            AuthenticationView()
                .environmentObject(authViewModel)
                .navigationBarBackButtonHidden(true)
        }
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
        .applyGradientBackground()
        .overlay(
            ErrorBannerView()
                .padding(.top, 50),
            alignment: .top
        )
    }
}

#Preview {
    NavigationStack {
        SignUpEmailView(showSignInView: .constant(false))
            .environmentObject(AuthViewModel())
    }
}
