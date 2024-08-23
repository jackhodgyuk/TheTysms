import SwiftUI

struct AdminView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedUser: AuthViewModel.User?
    @State private var showingRoleActionSheet = false
    @State private var showingCreateUserSheet = false
    @State private var showUpdateNameView = false

    var body: some View {
        NavigationView {
            List {
                ForEach(authViewModel.allUsers) { user in
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
                        showUpdateNameView = true
                        selectedUser = user
                    }
                }
                .onDelete(perform: deleteUser)
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
                    .cancel()
                ])
            }
            .sheet(isPresented: $showingCreateUserSheet) {
                CreateUserView()
            }
            .sheet(isPresented: $showUpdateNameView) {
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
    
    private func deleteUser(at offsets: IndexSet) {
        offsets.forEach { index in
            let user = authViewModel.allUsers[index]
            authViewModel.deleteUser(userId: user.id)
        }
    }
}
