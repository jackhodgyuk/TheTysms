import SwiftUI

struct CreateUserView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var name = ""
    @State private var role = "bandmember"
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Email", text: $email)
                TextField("Name", text: $name)
                Picker("Role", selection: $role) {
                    Text("Band Member").tag("bandmember")
                    Text("Manager").tag("manager")
                    Text("Admin").tag("admin")
                }
            }
            .navigationTitle("Create User")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                createUser()
            })
            .alert(isPresented: $showAlert) {
                Alert(title: Text("User Creation"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    if alertMessage == "User created successfully" {
                        presentationMode.wrappedValue.dismiss()
                    }
                })
            }
        }
    }

    private func createUser() {
        authViewModel.createUser(email: email, name: name, role: role) { error in
            if let error = error {
                alertMessage = error.localizedDescription
            } else {
                alertMessage = "User created successfully"
            }
            showAlert = true
        }
    }
}
