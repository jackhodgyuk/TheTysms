import SwiftUI
import Firebase
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var userRole: String = ""
    @State private var userName: String = ""
    @State private var showingChangePassword = false

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    Text(authViewModel.currentUser?.email ?? "")
                    Text("Role: \(userRole)")
                    Text("Name: \(userName)")
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
            .onAppear {
                fetchUserDetails()
            }
        }
    }

    private func fetchUserDetails() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                self.userRole = document.data()?["role"] as? String ?? "Unknown"
                self.userName = document.data()?["name"] as? String ?? "Not set"
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
