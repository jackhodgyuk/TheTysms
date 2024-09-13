import SwiftUI
import Firebase

@main
struct TheTysmsforMacApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
