import SwiftUI

struct SignUpEmailView: View {
    
    @StateObject private var viewModel = SignUpEmailViewModel()
    @Binding var showSignInView: Bool
    @State private var showSuccessMessage = false
    @State private var isNavigatedToSignInView = false
    
    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .textContentType(.newPassword)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            SecureField("Confirm Password...", text: $viewModel.confirmPassword)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
                .textContentType(.newPassword)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if viewModel.showErrorMessage {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
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
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign Up With Email")
        .alert(isPresented: $showSuccessMessage) {
            Alert(
                title: Text("Success"),
                message: Text("Your account has been created successfully!"),
                dismissButton: .default(Text("OK")) {
                    isNavigatedToSignInView = true
                }
            )
        }
        .navigationDestination(isPresented: $isNavigatedToSignInView) {
            AuthenticationView(showSignInView: $showSignInView)
        }
        .applyGradientBackground()
    }
}

#Preview {
    NavigationStack {
        SignUpEmailView(showSignInView: .constant(false))
    }
}
