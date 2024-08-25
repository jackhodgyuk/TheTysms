import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingChangePasswordAlert = false
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var showingResultAlert = false
    @State private var resultMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    Button("Logout") {
                        authViewModel.signOut()
                    }
                }
                
                Section(header: Text("Security")) {
                    Button("Change Password") {
                        showingChangePasswordAlert = true
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Change Password", isPresented: $showingChangePasswordAlert) {
                SecureField("Current Password", text: $currentPassword)
                SecureField("New Password", text: $newPassword)
                Button("Cancel", role: .cancel) {
                    resetPasswordFields()
                }
                Button("Confirm") {
                    changePassword()
                }
            }
            .alert("Password Change Result", isPresented: $showingResultAlert) {
                Button("OK", role: .cancel) {
                    resetPasswordFields()
                }
            } message: {
                Text(resultMessage)
            }
        }
    }
    
    private func changePassword() {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            resultMessage = "No user logged in"
            showingResultAlert = true
            return
        }
        
        // First, reauthenticate the user
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                resultMessage = "Failed to authenticate: \(error.localizedDescription)"
                showingResultAlert = true
                return
            }
            
            // If reauthentication successful, update the password
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    resultMessage = "Failed to change password: \(error.localizedDescription)"
                } else {
                    resultMessage = "Password changed successfully"
                }
                showingResultAlert = true
            }
        }
    }
    
    private func resetPasswordFields() {
        currentPassword = ""
        newPassword = ""
    }
}
