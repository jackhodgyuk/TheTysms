import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginButtonDisabled = false

    var body: some View {
        VStack(spacing: 20) {
            Text("The Tysms Admin")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textContentType(.password)
            }
            .padding(.horizontal)

            Button(action: {
                isLoginButtonDisabled = true
                authViewModel.signIn(email: email, password: password)
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(isLoginButtonDisabled)
            .padding(.horizontal)

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .frame(width: 300, height: 300)
        .onChange(of: authViewModel.isLoggedIn) { _ in
            isLoginButtonDisabled = false
        }
    }
}
