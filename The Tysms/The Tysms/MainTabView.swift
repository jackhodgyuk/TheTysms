import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        TabView {
            EventsView(eventViewModel: EventViewModel())
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
            
            FinancesView(viewModel: FinanceViewModel())
                .tabItem {
                    Label("Finances", systemImage: "dollarsign.circle")
                }
            
            SetlistView()
                .tabItem {
                    Label("Setlist", systemImage: "music.note.list")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            
            if authViewModel.currentUser?.role == "admin" {
                AdminView()
                    .tabItem {
                        Label("Admin", systemImage: "person.3")
                    }
            }
        }
    }
}
