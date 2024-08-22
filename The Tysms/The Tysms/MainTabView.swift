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
            
            if authViewModel.isManager() || authViewModel.isAdmin() {
                ManagerView()
                    .tabItem {
                        Label("Manage", systemImage: "person.2")
                    }
            }
            
            if authViewModel.isAdmin() {
                AdminView()
                    .tabItem {
                        Label("Admin", systemImage: "gear")
                    }
            }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .onAppear {
            print("MainTabView appeared")
            print("User role: \(authViewModel.currentUserRole ?? "nil")")
            print("Is admin: \(authViewModel.isAdmin())")
            print("Is manager: \(authViewModel.isManager())")
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
    }
}
