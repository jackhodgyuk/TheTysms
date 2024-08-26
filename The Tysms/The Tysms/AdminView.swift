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
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(authViewModel.allUsers, id: \.email) { user in
                            UserCard(user: user)
                                .onTapGesture {
                                    selectedUser = user
                                    showingRoleActionSheet = true
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Admin Panel")
            .navigationBarItems(trailing: addButton)
            .onAppear { authViewModel.fetchAllUsers() }
            .actionSheet(isPresented: $showingRoleActionSheet) { userActionSheet }
            .sheet(isPresented: $showingUpdateNameView) { updateNameView }
            .sheet(isPresented: $showingCreateUserView) { CreateUserView(isPresented: $showingCreateUserView) }
            .alert(isPresented: $showingPasswordResetAlert) { passwordResetAlert }
        }
    }
    
    private var addButton: some View {
        Button(action: { showingCreateUserView = true }) {
            Image(systemName: "plus")
                .foregroundColor(.white)
                .padding(10)
                .background(Color.blue)
                .clipShape(Circle())
        }
    }
    
    private var userActionSheet: ActionSheet {
        ActionSheet(title: Text("User Actions"), buttons: [
            .default(Text("Change Role to Band Member")) { updateRole("bandmember") },
            .default(Text("Change Role to Manager")) { updateRole("manager") },
            .default(Text("Change Role to Admin")) { updateRole("admin") },
            .default(Text("Update Name")) { showingUpdateNameView = true },
            .default(Text("Reset Password")) { if let user = selectedUser { resetPassword(for: user) } },
            .cancel()
        ])
    }
    
    private var updateNameView: some View {
        Group {
            if let user = selectedUser {
                UpdateUserNameView(userId: user.id, currentEmail: user.email)
            }
        }
    }
    
    private var passwordResetAlert: Alert {
        Alert(
            title: Text("Password Reset"),
            message: Text("Password reset email sent successfully."),
            dismissButton: .default(Text("OK"))
        )
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

struct UserCard: View {
    let user: AuthViewModel.User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(user.email)
                .font(.headline)
                .foregroundColor(.white)
            Text("Role: \(user.role)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            Text("Name: \(user.name.isEmpty ? "Not set" : user.name)")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
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
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Picker("Role", selection: $role) {
                        Text("Band Member").tag("bandmember")
                        Text("Manager").tag("manager")
                        Text("Admin").tag("admin")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
                .padding()
            }
            .navigationTitle("Create New User")
            .navigationBarItems(
                leading: Button("Cancel") { isPresented = false },
                trailing: Button("Save") { createUser() }
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
