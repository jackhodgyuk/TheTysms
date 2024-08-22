import SwiftUI
import Firebase
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var isLoading = true
    
    var isManager: Bool {
        // Replace this with actual logic to determine if the user is a manager
        return user?.email?.hasSuffix("@manager.com") ?? false
    }
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isLoading = false
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            // Handle sign in result
        }
    }
    
    func signOut() {
        try? Auth.auth().signOut()
    }
    
    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            // Handle password reset
        }
    }
}
