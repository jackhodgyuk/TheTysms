//
//  UpdateUserNameView.swift
//  The Tysms
//
//  Created by Jack Hodgy on 23/08/2024.
//


import SwiftUI

struct UpdateUserNameView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let userId: String
    let currentEmail: String
    @State private var name: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Update User Name")) {
                    Text("Email: \(currentEmail)")
                    TextField("Name", text: $name)
                }
            }
            .navigationTitle("Update Name")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Update") {
                    updateName()
                }
            )
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Name Update"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                if alertMessage.contains("successfully") {
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
    }
    
    private func updateName() {
        authViewModel.updateUserName(userId: userId, name: name) { success in
            if success {
                alertMessage = "Name updated successfully"
            } else {
                alertMessage = "Failed to update name. Please try again."
            }
            showingAlert = true
        }
    }
}

struct UpdateUserNameView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateUserNameView(userId: "previewUserId", currentEmail: "preview@example.com")
            .environmentObject(AuthViewModel())
    }
}
