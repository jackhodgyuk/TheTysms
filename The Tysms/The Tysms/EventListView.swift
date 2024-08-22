import SwiftUI

struct EventListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var eventViewModel = EventViewModel()
    @State private var showingAddEvent = false
    
    var body: some View {
        NavigationView {
            List(eventViewModel.events) { event in
                NavigationLink(destination: EventDetailView(eventViewModel: eventViewModel, event: event)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(event.title)
                                .font(.headline)
                            Text(event.date, style: .date)
                                .font(.subheadline)
                        }
                        Spacer()
                        if let userId = authViewModel.currentUser?.uid,
                           let response = event.responses[userId] {
                            Circle()
                                .fill(colorForResponse(response))
                                .frame(width: 20, height: 20)
                        }
                    }
                }
            }
            .navigationTitle("Events")
            .navigationBarItems(trailing: Group {
                if authViewModel.isManager() || authViewModel.isAdmin() {
                    Button(action: { showingAddEvent = true }) {
                        Image(systemName: "plus")
                    }
                }
            })
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(eventViewModel: eventViewModel)
            }
        }
    }
    
    func colorForResponse(_ response: String) -> Color {
        switch response {
        case "yes":
            return .green
        case "maybe":
            return .yellow
        case "no":
            return .red
        default:
            return .gray
        }
    }
}

struct EventListView_Previews: PreviewProvider {
    static var previews: some View {
        EventListView()
            .environmentObject(AuthViewModel())
    }
}
