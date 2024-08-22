//
//  CreateUserView.swift
//  The Tysms
//
//  Created by Jack Hodgy on 22/08/2024.
//


import SwiftUI

struct CreateUserView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email = ""
    @State private var name = ""
    @State private var role = "bandmember"
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Information")) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    TextField("Name", text: $name)
                    Picker("Role", selection: $role) {
                        Text("Band Member").tag("bandmember")
                        Text("Manager").tag("manager")
                        Text("Admin").tag("admin")
                    }
                }
            }
            .navigationTitle("Create User")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Create") {
                    createUser()
                }
            )
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("User Creation"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                if alertMessage.contains("successfully") {
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
    }
    
    private func createUser() {
        authViewModel.createUser(email: email, name: name, role: role) { success in
            if success {
                alertMessage = "User created successfully with default password: thetysms"
            } else {
                alertMessage = "Failed to create user. Please try again."
            }
            showingAlert = true
        }
    }
}

struct CreateUserView_Previews: PreviewProvider {
    static var previews: some View {
        CreateUserView()
            .environmentObject(AuthViewModel())
    }
}
