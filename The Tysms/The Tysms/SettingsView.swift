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
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    settingsSection(title: "Account") {
                        Button(action: {
                            authViewModel.signOut()
                        }) {
                            Text("Logout")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(10)
                        }
                    }
                    
                    settingsSection(title: "Security") {
                        Button(action: {
                            showingChangePasswordAlert = true
                        }) {
                            Text("Change Password")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
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
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            content()
        }
    }
    
    private func changePassword() {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            resultMessage = "No user logged in"
            showingResultAlert = true
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                resultMessage = "Failed to authenticate: \(error.localizedDescription)"
                showingResultAlert = true
                return
            }
            
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
