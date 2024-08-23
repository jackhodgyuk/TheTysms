import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                SecureField("Current Password", text: $currentPassword)
                SecureField("New Password", text: $newPassword)
                SecureField("Confirm New Password", text: $confirmPassword)
            }
            .navigationTitle("Change Password")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                changePassword()
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Change Password"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    if alertMessage == "Password changed successfully" {
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            }
        }
    }

    private func changePassword() {
        if newPassword != confirmPassword {
            alertMessage = "New passwords do not match"
            showAlert = true
            return
        }
        
        authViewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword) { error in
            if let error = error {
                alertMessage = error.localizedDescription
            } else {
                alertMessage = "Password changed successfully"
            }
            showAlert = true
        }
    }
}
