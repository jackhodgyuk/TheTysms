//
//  SettingsView.swift
//  The Tysms
//
//  Created by Jack Hodgy on 22/08/2024.
//


import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingChangePasswordAlert = false
    @State private var newPassword = ""
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    Button("Change Password") {
                        showingChangePasswordAlert = true
                    }
                    Button("Logout") {
                        showingLogoutAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .alert("Change Password", isPresented: $showingChangePasswordAlert) {
                TextField("New Password", text: $newPassword)
                Button("Cancel", role: .cancel) { }
                Button("Change") {
                    authViewModel.changePassword(newPassword: newPassword) { success in
                        if success {
                            print("Password changed successfully")
                        } else {
                            print("Failed to change password")
                        }
                    }
                }
            } message: {
                Text("Enter your new password")
            }
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    authViewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthViewModel())
    }
}
