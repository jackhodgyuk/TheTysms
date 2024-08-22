import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    struct UserRole: Identifiable, Codable {
        @DocumentID var id: String?
        var userid: String
        var email: String
        var role: String
    }

    @Published var user: FirebaseAuth.User?
    @Published var userRole: UserRole?
    @Published var isLoading = true
    
    private var db = Firestore.firestore()
    
    init() {
        print("AuthViewModel initialized")
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            print("Auth state changed. User: \(user?.uid ?? "nil")")
            self?.user = user
            if let user = user {
                self?.fetchUserRole(for: user.uid)
            } else {
                self?.userRole = nil
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
            self.user = nil
            self.userRole = nil
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
            
            if let document = document, document.exists {
                do {
                    let userRole = try document.data(as: UserRole.self)
                    DispatchQueue.main.async {
                        self?.userRole = userRole
                        self?.isLoading = false
                        print("User role fetched successfully: \(userRole.role)")
                    }
                } catch {
                    print("Error decoding user role: \(error.localizedDescription)")
                    if let data = document.data() {
                        print("Document data: \(data)")
                        // Manually create UserRole from the document data
                        if let email = data["email"] as? String,
                           let role = data["role"] as? String,
                           let userid = data["userid"] as? String {
                            let userRole = UserRole(id: document.documentID, userid: userid, email: email, role: role)
                            DispatchQueue.main.async {
                                self?.userRole = userRole
                                self?.isLoading = false
                                print("User role manually created: \(userRole.role)")
                            }
                        } else {
                            print("Failed to manually create UserRole from document data")
                            self?.isLoading = false
                        }
                    } else {
                        self?.isLoading = false
                    }
                }
            } else {
                print("User role document does not exist for userId: \(userId)")
                self?.isLoading = false
            }
        }
    }
    
    func isAdmin() -> Bool {
        let isAdmin = userRole?.role.lowercased() == "admin"
        print("Checking if user is admin: \(isAdmin) (userRole: \(String(describing: userRole)))")
        return isAdmin
    }
    
    func isManager() -> Bool {
        let isManager = userRole?.role.lowercased() == "manager" || isAdmin()
        print("Checking if user is manager: \(isManager) (userRole: \(String(describing: userRole)))")
        return isManager
    }
    
    func isBandMember() -> Bool {
        let isBandMember = userRole?.role.lowercased() == "bandmember" || isManager()
        print("Checking if user is band member: \(isBandMember)")
        return isBandMember
    }
    
    func assignRole(to email: String, role: String) {
        print("Attempting to assign role \(role) to email: \(email)")
        guard isAdmin() else {
            print("Only admins can assign roles")
            return
        }
        
        Auth.auth().fetchSignInMethods(forEmail: email) { [weak self] methods, error in
            if let error = error {
                print("Error fetching sign-in methods: \(error.localizedDescription)")
                return
            }
            
            if methods?.isEmpty ?? true {
                print("User does not exist")
                return
            }
            
            self?.db.collection("userRoles").whereField("email", isEqualTo: email).getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching user role: \(error.localizedDescription)")
                    return
                }
                
                if let document = querySnapshot?.documents.first {
                    // Update existing role
                    document.reference.updateData(["role": role]) { error in
                        if let error = error {
                            print("Error updating user role: \(error.localizedDescription)")
                        } else {
                            print("User role updated successfully")
                        }
                    }
                } else {
                    // Create new role
                    let newRole = UserRole(userid: "", email: email, role: role)
                    do {
                        try self?.db.collection("userRoles").addDocument(from: newRole) { error in
                            if let error = error {
                                print("Error creating user role: \(error.localizedDescription)")
                            } else {
                                print("New user role created successfully")
                            }
                        }
                    } catch {
                        print("Error creating user role: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
