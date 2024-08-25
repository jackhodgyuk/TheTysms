import SwiftUI
import Firebase

struct EventsView: View {
    @ObservedObject var eventViewModel: EventViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddEvent = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Upcoming Events")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(eventViewModel.events) { event in
                                NavigationLink(destination: EventDetailView(eventViewModel: eventViewModel, event: event)) {
                                    EventCard(event: event, userId: authViewModel.currentUser?.uid ?? "")
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarItems(trailing: addButton)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            eventViewModel.fetchEvents()
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView(eventViewModel: eventViewModel)
        }
    }
    
    private var addButton: some View {
        Group {
            if authViewModel.isAdminOrManager() {
                Button(action: {
                    showingAddEvent = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                }
            }
        }
    }
}

struct EventCard: View {
    let event: Event
    let userId: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(event.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text(event.location)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
            Circle()
                .fill(responseColor)
                .frame(width: 20, height: 20)
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
    }
    
    private var responseColor: Color {
        guard let response = event.responses[userId] else {
            return .gray
        }
        
        switch response.lowercased() {
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

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView(eventViewModel: EventViewModel())
            .environmentObject(AuthViewModel())
    }
}
