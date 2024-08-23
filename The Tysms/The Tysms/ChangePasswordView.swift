//
//  ChangePasswordView.swift
//  The Tysms
//
//  Created by Jack Hodgy on 23/08/2024.
//


import SwiftUI

struct ChangePasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                SecureField("Current Password", text: $currentPassword)
                SecureField("New Password", text: $newPassword)
                SecureField("Confirm New Password", text: $confirmNewPassword)
                
                Button("Change Password") {
                    if newPassword == confirmNewPassword {
                        authViewModel.changePassword(currentPassword: currentPassword, newPassword: newPassword) { success, error in
                            if success {
                                alertMessage = "Password changed successfully"
                                showAlert = true
                            } else {
                                alertMessage = error?.localizedDescription ?? "Failed to change password"
                                showAlert = true
                            }
                        }
                    } else {
                        alertMessage = "New passwords do not match"
                        showAlert = true
                    }
                }
            }
            .navigationTitle("Change Password")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Password Change"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    if alertMessage == "Password changed successfully" {
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            }
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView()
            .environmentObject(AuthViewModel())
    }
}
