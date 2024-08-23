import SwiftUI

struct UpdateUserNameView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    let userId: String
    let currentEmail: String
    @State private var newName = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("New Name", text: $newName)
            }
            .navigationTitle("Update Name")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                updateName()
            })
        }
    }

    private func updateName() {
        authViewModel.updateUserName(userId: userId, newName: newName) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
