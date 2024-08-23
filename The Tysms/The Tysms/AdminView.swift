import SwiftUI

struct AdminView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedUser: AuthViewModel.User?
    @State private var showingRoleActionSheet = false
    @State private var showingUpdateNameView = false

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
        }
    }
    
    private func updateRole(_ newRole: String) {
        if let userId = selectedUser?.id {
            authViewModel.updateUserRole(userId: userId, newRole: newRole)
        }
    }
    
    private func resetPassword(for user: AuthViewModel.User) {
        authViewModel.resetUserPassword(email: user.email)
    }
}
