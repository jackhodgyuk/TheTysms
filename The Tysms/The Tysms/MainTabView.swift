import SwiftUI

struct MainTabView: View {
    @StateObject private var financeViewModel = FinanceViewModel()
    @StateObject private var eventViewModel = EventViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

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
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            
            if authViewModel.currentUser?.isAdmin == true {
                AdminView()
                    .tabItem {
                        Label("Admin", systemImage: "person.3")
                    }
            }
        }
    }
}
