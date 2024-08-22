import SwiftUI

struct AdminView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedUser: AuthViewModel.User?
    @State private var showingRoleActionSheet = false
    @State private var showingResetPasswordAlert = false
    @State private var showingCreateUserSheet = false
    @State private var showingCreateUserResultAlert = false
    @State private var createUserResultMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(authViewModel.allUsers) { user in
                    VStack(alignment: .leading) {
                        Text(user.email)
                            .font(.headline)
                        Text("Role: \(user.role)")
                            .font(.subheadline)
                    }
                    .onTapGesture {
                        selectedUser = user
                        showingRoleActionSheet = true
                    }
                }
            }
            .navigationTitle("Admin Panel")
            .navigationBarItems(trailing:
                Button(action: {
                    showingCreateUserSheet = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .onAppear {
                authViewModel.fetchAllUsers()
            }
            .actionSheet(isPresented: $showingRoleActionSheet) {
                ActionSheet(title: Text("Change Role"), buttons: [
                    .default(Text("Band Member")) { updateRole("bandmember") },
                    .default(Text("Manager")) { updateRole("manager") },
                    .default(Text("Admin")) { updateRole("admin") },
                    .destructive(Text("Reset Password")) {
                        showingResetPasswordAlert = true
                    },
                    .cancel()
                ])
            }
            .alert(isPresented: $showingResetPasswordAlert) {
                Alert(
                    title: Text("Reset Password"),
                    message: Text("Are you sure you want to reset the password for \(selectedUser?.email ?? "")?"),
                    primaryButton: .destructive(Text("Reset")) {
                        if let email = selectedUser?.email {
                            authViewModel.resetUserPassword(email: email)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showingCreateUserSheet) {
                CreateUserView(isPresented: $showingCreateUserSheet, showingResultAlert: $showingCreateUserResultAlert, resultMessage: $createUserResultMessage)
            }
            .alert(isPresented: $showingCreateUserResultAlert) {
                Alert(title: Text("User Creation"), message: Text(createUserResultMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func updateRole(_ newRole: String) {
        if let userId = selectedUser?.id {
            authViewModel.updateUserRole(userId: userId, newRole: newRole)
        }
    }
}

struct CreateUserView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var isPresented: Bool
    @Binding var showingResultAlert: Bool
    @Binding var resultMessage: String
    @State private var email = ""
    @State private var role = "bandmember"
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                Picker("Role", selection: $role) {
                    Text("Band Member").tag("bandmember")
                    Text("Manager").tag("manager")
                    Text("Admin").tag("admin")
                }
            }
            .navigationTitle("Create User")
            .navigationBarItems(
                leading: Button("Cancel") { isPresented = false },
                trailing: Button("Create") {
                    authViewModel.createUser(email: email, role: role) { success in
                        if success {
                            resultMessage = "User created successfully with default password: thetysms"
                        } else {
                            resultMessage = "Failed to create user. Please try again."
                        }
                        isPresented = false
                        showingResultAlert = true
                    }
                }
            )
        }
    }
}

struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView()
            .environmentObject(AuthViewModel())
    }
}
