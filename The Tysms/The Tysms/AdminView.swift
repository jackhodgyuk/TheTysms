import SwiftUI

struct AdminView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedUser: AuthViewModel.User?
    @State private var showingRoleActionSheet = false
    @State private var showingUpdateNameView = false
    @State private var showingCreateUserView = false
    @State private var showingPasswordResetAlert = false

    var body: some View {
        NavigationView {
            List {
                ForEach(authViewModel.allUsers, id: \.email) { user in
                    VStack(alignment: .leading) {
                        Text(user.email)
                            .font(.headline)
                        Text("Role: \(user.role)")
                            .font(.subheadline)
                        Text("Name: \(user.name.isEmpty ? "Not set" : user.name)")
                            .font(.subheadline)
                    }
                    .onTapGesture {
                        selectedUser = user
                        showingRoleActionSheet = true
                    }
                    Button("Update Name") {
                        showingUpdateNameView = true
                        selectedUser = user
                    }
                    Button("Reset Password") {
                        resetPassword(for: user)
                    }
                }
            }
            .navigationTitle("Admin Panel")
            .navigationBarItems(trailing: Button(action: {
                showingCreateUserView = true
            }) {
                Image(systemName: "plus")
            })
            .onAppear {
                authViewModel.fetchAllUsers()
            }
            .actionSheet(isPresented: $showingRoleActionSheet) {
                ActionSheet(title: Text("Change Role"), buttons: [
                    .default(Text("Band Member")) { updateRole("bandmember") },
                    .default(Text("Manager")) { updateRole("manager") },
                    .default(Text("Admin")) { updateRole("admin") },
                    .cancel()
                ])
            }
            .sheet(isPresented: $showingUpdateNameView) {
                if let user = selectedUser {
                    UpdateUserNameView(userId: user.id, currentEmail: user.email)
                }
            }
            .sheet(isPresented: $showingCreateUserView) {
                CreateUserView(isPresented: $showingCreateUserView)
            }
            .alert(isPresented: $showingPasswordResetAlert) {
                Alert(
                    title: Text("Password Reset"),
                    message: Text("Password reset email sent successfully."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func updateRole(_ newRole: String) {
        if let userId = selectedUser?.id {
            authViewModel.updateUserRole(userId: userId, newRole: newRole)
        }
    }
    
    private func resetPassword(for user: AuthViewModel.User) {
        authViewModel.resetUserPassword(email: user.email)
        showingPasswordResetAlert = true
    }
}

struct CreateUserView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var isPresented: Bool
    @State private var email = ""
    @State private var name = ""
    @State private var role = "bandmember"
    @State private var showingAlert = false
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
            .navigationTitle("Create New User")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    createUser()
                }
            )
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("User Creation"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    if alertMessage == "User created successfully" {
                        isPresented = false
                    }
                })
            }
        }
    }

    private func createUser() {
        authViewModel.createUser(email: email, name: name, role: role) { success in
            if success {
                alertMessage = "User created successfully"
                authViewModel.fetchAllUsers()
            } else {
                alertMessage = "Failed to create user"
            }
            showingAlert = true
        }
    }
}
