import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            EventListView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
            
            SetlistView()
                .tabItem {
                    Label("Setlist", systemImage: "music.note.list")
                }
            
            FinanceRequestView()
                .tabItem {
                    Label("Finances", systemImage: "dollarsign.circle")
                }
            
            if authViewModel.isManager() {
                ManagerView()
                    .tabItem {
                        Label("Manage", systemImage: "person.2")
                    }
            }
        }
        .onAppear {
            print("MainTabView appeared")
            print("User role: \(authViewModel.userRole?.role ?? "nil")")
            print("Is admin: \(authViewModel.isAdmin())")
            print("Is manager: \(authViewModel.isManager())")
        }
    }
}
