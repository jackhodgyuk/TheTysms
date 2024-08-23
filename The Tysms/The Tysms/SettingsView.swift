import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            List {
                Button("Logout") {
                    authViewModel.signOut()
                }
            }
            .navigationTitle("Settings")
        }
    }
}
