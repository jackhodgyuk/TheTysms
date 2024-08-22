import SwiftUI

struct AdminView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var selectedRole = "bandmember"
    
    let roleOptions = ["admin", "manager", "bandmember"]
    
    var body: some View {
        Form {
            Section(header: Text("Assign Role")) {
                TextField("User Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                Picker("Role", selection: $selectedRole) {
                    ForEach(roleOptions, id: \.self) { role in
                        Text(role.capitalized).tag(role)
                    }
                }
                
                Button("Assign Role") {
                    authViewModel.assignRole(to: email, role: selectedRole)
                    email = ""
                }
            }
        }
        .navigationTitle("Admin Panel")
    }
}

struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView()
            .environmentObject(AuthViewModel())
    }
}
