import SwiftUI
import Firebase
import FirebaseFirestoreSwift

@main
struct TheTysmsApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}

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
        VStack {
            Image("TheTysmsLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            Text("The Tysms")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                // Transition to next screen
            }
        }
    }
}
