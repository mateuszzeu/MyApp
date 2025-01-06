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
                .applyTransparentBackground()
            
            SecureField("Password...", text: $viewModel.password)
                .padding()
                .applyTransparentBackground()
                .textContentType(.newPassword)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            SecureField("Confirm Password...", text: $viewModel.confirmPassword)
                .padding()
                .applyTransparentBackground()
                .textContentType(.newPassword)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if viewModel.showErrorMessage {
                Text(viewModel.errorMessage)
                   // .foregroundColor(.red)
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
                    //.foregroundColor(.white)
                    .foregroundColor(Color.theme.text)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    //.background(Color.green)
                    .background(Color.theme.primary)
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showSuccessMessage) {
            SuccessSheetView {
                isNavigatedToSignInView = true
                showSuccessMessage = false
            }
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
