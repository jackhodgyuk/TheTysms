import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isAnimating = false
    @State private var showingForgotPasswordAlert = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Logo
                Image("TysmsLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.top, 50)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                
                // Login form
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .textFieldStyle(ModernTextFieldStyle())
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(ModernTextFieldStyle())
                    
                    Button(action: {
                        authViewModel.signIn(email: email, password: password)
                    }) {
                        Text("LOGIN")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Forgot Password button
                Button("Forgot Password?") {
                    showingForgotPasswordAlert = true
                }
                .foregroundColor(.white)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            isAnimating = true
        }
        .alert(isPresented: $showingForgotPasswordAlert) {
             Alert(
                title: Text("Forgot Password"),
                message: Text("Contact Jack Hodgy to send your password reset link."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .foregroundColor(.white)
            .accentColor(.white)
            .autocapitalization(.none)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
