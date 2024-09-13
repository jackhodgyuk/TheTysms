import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    struct User: Identifiable {
        let id: String
        var email: String
        var name: String
        var role: String
    }

    @Published var currentUser: FirebaseAuth.User?
    @Published var currentUserRole: String?
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var isLoggedIn = false
    @Published var allUsers: [User] = []

    private var db = Firestore.firestore()

    init() {
        print("AuthViewModel initialized")
        checkAuthState()
    }

    private func checkAuthState() {
        if let uid = UserDefaults.standard.string(forKey: "userUID") {
            Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
                if let user = user, user.uid == uid {
                    self?.currentUser = user
                    self?.isLoggedIn = true
                    self?.fetchUserRole(for: user.uid)
                } else {
                    self?.signOut()
                }
            }
        } else {
            self.isLoggedIn = false
            self.isLoading = false
        }
    }

    func signIn(email: String, password: String) {
        print("Attempting to sign in with email: \(email)")
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                self?.errorMessage = "Sign in failed: \(error.localizedDescription)"
                self?.isLoggedIn = false
            } else {
                print("Sign in successful")
                if let user = result?.user {
                    self?.currentUser = user
                    self?.isLoggedIn = true
                    UserDefaults.standard.set(user.uid, forKey: "userUID")
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
            self.isLoggedIn = false
            UserDefaults.standard.removeObject(forKey: "userUID")
            print("Sign out successful")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            self.errorMessage = "Error signing out: \(error.localizedDescription)"
        }
    }

    func fetchUserRole(for userId: String) {
        print("Fetching user role for userId: \(userId)")
        db.collection("userRoles").document(userId).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching user role: \(error.localizedDescription)")
                self?.isLoading = false
                self?.errorMessage = "Error fetching user role: \(error.localizedDescription)"
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
                self?.errorMessage = "User role not found"
            }
        }
    }

    func isAdmin() -> Bool {
        return currentUserRole?.lowercased() == "admin"
    }

    func fetchAllUsers() {
        db.collection("users").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No users found")
                return
            }
            
            self?.allUsers = documents.compactMap { document in
                let data = document.data()
                let id = document.documentID
                let email = data["email"] as? String ?? ""
                let name = data["name"] as? String ?? ""
                let role = data["role"] as? String ?? ""
                return User(id: id, email: email, name: name, role: role)
            }
        }
    }

    func createUser(email: String, password: String, name: String, role: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                completion(false, "Error creating user: \(error.localizedDescription)")
                return
            }
            
            guard let userId = authResult?.user.uid else {
                completion(false, "Failed to get user ID after creation")
                return
            }
            
            let userData: [String: Any] = [
                "email": email,
                "name": name,
                "role": role
            ]
            
            self?.db.collection("users").document(userId).setData(userData) { error in
                if let error = error {
                    completion(false, "Error saving user data: \(error.localizedDescription)")
                } else {
                    self?.fetchAllUsers()
                    completion(true, nil)
                }
            }
        }
    }

    func updateUser(userId: String, name: String, role: String, completion: @escaping (Bool, String?) -> Void) {
        let userData: [String: Any] = [
            "name": name,
            "role": role
        ]
        
        db.collection("users").document(userId).updateData(userData) { [weak self] error in
            if let error = error {
                completion(false, "Error updating user: \(error.localizedDescription)")
            } else {
                self?.fetchAllUsers()
                completion(true, nil)
            }
        }
    }

    func deleteUser(userId: String, completion: @escaping (Bool, String?) -> Void) {
        db.collection("users").document(userId).delete { [weak self] error in
            if let error = error {
                completion(false, "Error deleting user document: \(error.localizedDescription)")
            } else {
                self?.fetchAllUsers()
                completion(true, nil)
            }
        }
    }
}
