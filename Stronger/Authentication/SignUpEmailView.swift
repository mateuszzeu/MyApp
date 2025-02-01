import SwiftUI

struct SignUpEmailView: View {
    
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
            
            if viewModel.showErrorMessage {
                Text(viewModel.errorMessage)
                    .foregroundColor(Color.theme.accent)
                    .font(.footnote)
                    .padding(.top, 10)
            }
            
            Button {
                Task {
                    do {
                        guard viewModel.isValidData() else {
                            viewModel.showErrorMessage = true
                            return
                        }
                        try await viewModel.signUp()
                        showSuccessMessage = true
                    } catch {
                        print("Sign up error: \(error.localizedDescription)")
                        viewModel.errorMessage = "Error creating user"
                        viewModel.showErrorMessage = true
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
            AuthenticationView(showSignInView: $showSignInView)
                .navigationBarBackButtonHidden(true)
        }
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.inline)
        .applyGradientBackground()
    }
}

#Preview {
    NavigationStack {
        SignUpEmailView(showSignInView: .constant(false))
    }
}
