import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    struct User: Identifiable {
        let id: String
        let email: String
        var role: String
        var name: String
    }

    @Published var currentUser: FirebaseAuth.User?
    @Published var currentUserRole: String?
    @Published var isLoading = true
    @Published var allUsers: [User] = []
    
    private var db = Firestore.firestore()
    
    init() {
        print("AuthViewModel initialized")
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            print("Auth state changed. User: \(user?.uid ?? "nil")")
            self?.currentUser = user
            if let user = user {
                self?.fetchUserRole(for: user.uid)
            } else {
                self?.currentUserRole = nil
                self?.isLoading = false
            }
        }
    }
    
    func signIn(email: String, password: String) {
        print("Attempting to sign in with email: \(email)")
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
            } else {
                print("Sign in successful")
                if let user = result?.user {
                    self?.fetchUserRole(for: user.uid)
                }
            }
        }
    }
    
    func signOut() {
        print("Attempting to sign out")
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            self.currentUserRole = nil
            print("Sign out successful")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func resetPassword(email: String) {
        print("Attempting to reset password for email: \(email)")
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Error resetting password: \(error.localizedDescription)")
            } else {
                print("Password reset email sent successfully")
            }
        }
    }
    
    func fetchUserRole(for userId: String) {
        print("Fetching user role for userId: \(userId)")
        db.collection("userRoles").document(userId).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching user role: \(error.localizedDescription)")
                self?.isLoading = false
                return
            }
            
            if let document = document, document.exists, let role = document.data()?["role"] as? String {
                DispatchQueue.main.async {
                    self?.currentUserRole = role
                    self?.isLoading = false
                    print("User role fetched successfully: \(role)")
                }
            } else {
                print("User role document does not exist for userId: \(userId)")
                self?.isLoading = false
            }
        }
    }
    
    func isAdmin() -> Bool {
        return currentUserRole?.lowercased() == "admin"
    }
    
    func isManager() -> Bool {
        return currentUserRole?.lowercased() == "manager" || isAdmin()
    }
    
    func isBandMember() -> Bool {
        return currentUserRole?.lowercased() == "bandmember" || isManager()
    }
    
    func isAdminOrManager() -> Bool {
        return isAdmin() || isManager()
    }
    
    func fetchAllUsers() {
        db.collection("userRoles").getDocuments { [weak self] querySnapshot, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No users found")
                return
            }
            
            self?.allUsers = documents.compactMap { document in
                guard let email = document.data()["email"] as? String,
                      let role = document.data()["role"] as? String else {
                    return nil
                }
                let name = document.data()["name"] as? String ?? ""
                return User(id: document.documentID, email: email, role: role, name: name)
            }
        }
    }
    
    func updateUserRole(userId: String, newRole: String) {
        db.collection("userRoles").document(userId).setData(["role": newRole], merge: true) { error in
            if let error = error {
                print("Error updating user role: \(error.localizedDescription)")
            } else {
                print("User role updated successfully")
                self.fetchAllUsers()
            }
        }
    }
    
    func resetUserPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Error resetting password: \(error.localizedDescription)")
            } else {
                print("Password reset email sent successfully")
            }
        }
    }
    
    func createUser(email: String, name: String, role: String, completion: @escaping (Bool) -> Void) {
        let defaultPassword = "thetysms"
        
        Auth.auth().createUser(withEmail: email, password: defaultPassword) { [weak self] authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let userId = authResult?.user.uid else {
                print("Failed to get user ID after creation")
                completion(false)
                return
            }
            
            self?.db.collection("userRoles").document(userId).setData([
                "email": email,
                "name": name,
                "role": role
            ]) { error in
                if let error = error {
                    print("Error saving user role: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("User created and role saved successfully")
                    self?.fetchAllUsers()
                    completion(true)
                }
            }
        }
    }
    
    func changePassword(newPassword: String, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        user.updatePassword(to: newPassword) { error in
            if let error = error {
                print("Error changing password: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Password changed successfully")
                completion(true)
            }
        }
    }
    
    func updateUserName(userId: String, name: String, completion: @escaping (Bool) -> Void) {
        db.collection("userRoles").document(userId).updateData(["name": name]) { error in
            if let error = error {
                print("Error updating user name: \(error.localizedDescription)")
                completion(false)
            } else {
                print("User name updated successfully")
                self.fetchAllUsers()
                completion(true)
            }
        }
    }
}
