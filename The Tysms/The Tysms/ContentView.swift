import SwiftUI
import Firebase

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var eventViewModel = EventViewModel()
    @State private var selectedEvent: Event?
    
    var body: some View {
        Group {
            if authViewModel.isLoading {
                ProgressView("Loading...")
            } else if authViewModel.currentUser == nil {
                LoginView()
            } else {
                MainTabView()
                    .environmentObject(eventViewModel)
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("EventNotification"))) { notification in
                        if let eventTitle = notification.userInfo?["event"] as? String {
                            // Find the event with this title and set it as selectedEvent
                            // You might need to fetch the full event details from Firestore here
                            selectedEvent = Event(title: eventTitle, date: Date(), location: "", description: "")
                        }
                    }
                    .sheet(item: $selectedEvent) { event in
                        EventDetailView(eventViewModel: eventViewModel, event: event)
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}
