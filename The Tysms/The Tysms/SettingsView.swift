import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingChangePassword = false

    var body: some View {
        NavigationView {
            List {
                Button("Change Password") {
                    showingChangePassword = true
                }
                Button("Logout") {
                    authViewModel.signOut()
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingChangePassword) {
                ChangePasswordView()
            }
        }
    }
}
