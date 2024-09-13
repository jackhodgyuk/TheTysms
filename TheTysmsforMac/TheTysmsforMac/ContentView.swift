import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isLoading {
                ProgressView("Loading...")
            } else if authViewModel.isLoggedIn && authViewModel.isAdmin() {
                MainView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Dashboard", destination: DashboardView())
                NavigationLink("Users", destination: UsersView())
                NavigationLink("Finances", destination: FinancesView())
                NavigationLink("Events", destination: EventsView())
                NavigationLink("Setlist", destination: SetlistView())
            }
            .navigationTitle("Admin Panel")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Logout") {
                        authViewModel.signOut()
                    }
                }
            }
        }
    }
}
