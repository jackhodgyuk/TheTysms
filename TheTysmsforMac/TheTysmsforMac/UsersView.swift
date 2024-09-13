import SwiftUI

struct UsersView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddUserSheet = false
    @State private var showingEditUserSheet = false
    @State private var selectedUser: AuthViewModel.User?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        List {
            ForEach(authViewModel.allUsers) { user in
                VStack(alignment: .leading) {
                    Text(user.name)
                        .font(.headline)
                    Text(user.email)
                        .font(.subheadline)
                    Text("Role: \(user.role)")
                        .font(.subheadline)
                }
                .contextMenu {
                    Button("Edit") {
                        selectedUser = user
                        showingEditUserSheet = true
                    }
                    Button("Delete", role: .destructive) {
                        selectedUser = user
                        showingDeleteAlert = true
                    }
                }
            }
        }
        .navigationTitle("Users")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddUserSheet = true }) {
                    Label("Add User", systemImage: "person.badge.plus")
                }
            }
        }
        .sheet(isPresented: $showingAddUserSheet) {
            AddUserView()
        }
        .sheet(isPresented: $showingEditUserSheet) {
            if let user = selectedUser {
                EditUserView(user: user)
            }
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete User"),
                message: Text("Are you sure you want to delete this user?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let user = selectedUser {
                        deleteUser(user)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            authViewModel.fetchAllUsers()
        }
    }
    
    private func deleteUser(_ user: AuthViewModel.User) {
        authViewModel.deleteUser(userId: user.id) { success, error in
            if success {
                print("User deleted successfully")
            } else if let error = error {
                print("Error deleting user: \(error)")
            }
        }
    }
}

struct AddUserView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var role = "user"
    @State private var errorMessage: String?
    
    let roles = ["user", "admin", "manager"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Information")) {
                    TextField("Email", text: $email)
                        .textCase(.lowercase)
                        .disableAutocorrection(true)
                    SecureField("Password", text: $password)
                    TextField("Name", text: $name)
                    Picker("Role", selection: $role) {
                        ForEach(roles, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Add User")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        createUser()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func createUser() {
        authViewModel.createUser(email: email, password: password, name: name, role: role) { success, error in
            if success {
                presentationMode.wrappedValue.dismiss()
            } else if let error = error {
                errorMessage = error
            }
        }
    }
}

struct EditUserView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var name: String
    @State private var role: String
    @State private var errorMessage: String?
    
    let user: AuthViewModel.User
    let roles = ["user", "admin", "manager"]
    
    init(user: AuthViewModel.User) {
        self.user = user
        _name = State(initialValue: user.name)
        _role = State(initialValue: user.role)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Information")) {
                    TextField("Name", text: $name)
                    Picker("Role", selection: $role) {
                        ForEach(roles, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Edit User")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        updateUser()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func updateUser() {
        authViewModel.updateUser(userId: user.id, name: name, role: role) { success, error in
            if success {
                presentationMode.wrappedValue.dismiss()
            } else if let error = error {
                errorMessage = error
            }
        }
    }
}
