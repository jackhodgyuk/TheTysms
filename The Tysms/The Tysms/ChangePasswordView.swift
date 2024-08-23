import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reset Password")) {
                    TextField("Email", text: $email)
                }
                
                Section {
                    Button("Reset Password") {
                        resetPassword()
                    }
                }
            }
            .navigationTitle("Reset Password")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Password Reset"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")) {
                    if alertMessage == "Password reset email sent successfully" {
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            }
        }
    }
    
    private func resetPassword() {
        authViewModel.resetUserPassword(email: email)
        alertMessage = "Password reset email sent successfully"
        showAlert = true
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
            .environmentObject(AuthViewModel())
    }
}
