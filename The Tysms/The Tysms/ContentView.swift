import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isLoading {
                SplashScreen()
            } else if authViewModel.user == nil {
                LoginView()
            } else {
                MainTabView()
            }
        }
    }
}

struct SplashScreen: View {
    var body: some View {
        Text("Loading...")
    }
}
