import SwiftUI

struct UpdateUserNameView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    let userId: String
    let currentEmail: String
    @State private var newName = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

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
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Update Name"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func updateName() {
        authViewModel.updateUserName(userId: userId, name: newName) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            } else {
                alertMessage = "Failed to update name"
                showAlert = true
            }
        }
    }
}
