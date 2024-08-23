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
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
            
            if authViewModel.currentUser?.isAdmin == true {
                AdminView()
                    .tabItem {
                        Label("Admin", systemImage: "gear")
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
