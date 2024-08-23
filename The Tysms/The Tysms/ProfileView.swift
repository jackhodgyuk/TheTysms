import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingChangePassword = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    Text(authViewModel.currentUser?.email ?? "")
                    Text("Role: \(authViewModel.currentUser?.role ?? "")")
                    Text("Name: \(authViewModel.currentUser?.name ?? "Not set")")
                }
                
                Section {
                    Button("Change Password") {
                        showingChangePassword = true
                    }
                }
                
                Section {
                    Button("Logout") {
                        authViewModel.signOut()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showingChangePassword) {
                ChangePasswordView()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
