import SwiftUI

struct AdminView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var selectedRole: UserType = .bandMember
    
    var body: some View {
        Form {
            Section(header: Text("Assign Role")) {
                TextField("User Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                Picker("Role", selection: $selectedRole) {
                    Text("Band Member").tag(UserType.bandMember)
                    Text("Manager").tag(UserType.manager)
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
