import SwiftUI
import Firebase
import FirebaseAuth

struct MainTabView: View {
    @StateObject private var financeViewModel = FinanceViewModel()
    @StateObject private var eventViewModel = EventViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isAdmin = false

    var body: some View {
        TabView {
            EventsView(eventViewModel: eventViewModel)
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
            
            FinancesView(viewModel: financeViewModel)
                .tabItem {
                    Label("Finances", systemImage: "dollarsign.circle")
                }
            
            SetlistView()
                .tabItem {
                    Label("Setlist", systemImage: "music.note.list")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
            
            if isAdmin {
                AdminView()
                    .tabItem {
                        Label("Admin", systemImage: "gear")
                    }
            }
        }
        .onAppear {
            checkAdminStatus()
        }
    }

    private func checkAdminStatus() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                if let role = document.data()?["role"] as? String, role == "admin" {
                    self.isAdmin = true
                }
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
    }
}
