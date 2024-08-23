import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var eventViewModel: EventViewModel
    let event: Event
    
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(event.title)
                    .font(.title)
                Text(event.date, style: .date)
                    .font(.subheadline)
                Text(event.location)
                    .font(.subheadline)
                Text(event.description)
                    .padding(.top)
                
                ResponseButtons(event: event, eventViewModel: eventViewModel)
                
                if authViewModel.isManager() || authViewModel.isAdmin() {
                    ResponseList(eventViewModel: eventViewModel, event: event)
                    
                    Button(action: { showingDeleteAlert = true }) {
                        Text("Delete Event")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .padding(.top)
                }
            }
            .padding()
        }
        .navigationTitle("Event Details")
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Event"),
                message: Text("Are you sure you want to delete this event?"),
                primaryButton: .destructive(Text("Delete")) {
                    deleteEvent()
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            eventViewModel.fetchUserNames()
        }
    }
    
    private func deleteEvent() {
        if let eventId = event.id {
            eventViewModel.deleteEvent(eventId: eventId)
        }
    }
}

struct ResponseButtons: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let event: Event
    @ObservedObject var eventViewModel: EventViewModel
    
    var body: some View {
        HStack {
            Button("Yes") { updateResponse("yes") }
                .buttonStyle(CustomResponseButtonStyle(color: .green, isSelected: isSelected("yes")))
            Button("Maybe") { updateResponse("maybe") }
                .buttonStyle(CustomResponseButtonStyle(color: .yellow, isSelected: isSelected("maybe")))
            Button("No") { updateResponse("no") }
                .buttonStyle(CustomResponseButtonStyle(color: .red, isSelected: isSelected("no")))
            Button("Clear") { updateResponse(nil) }
                .buttonStyle(CustomResponseButtonStyle(color: .gray, isSelected: false))
        }
    }
    
    func updateResponse(_ response: String?) {
        guard let userId = authViewModel.currentUser?.uid, let eventId = event.id else { return }
        eventViewModel.updateEventResponse(eventId: eventId, userId: userId, response: response)
    }
    
    func isSelected(_ response: String) -> Bool {
        guard let userId = authViewModel.currentUser?.uid else { return false }
        return event.responses[userId] == response
    }
}

struct ResponseList: View {
    @ObservedObject var eventViewModel: EventViewModel
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Responses")
                .font(.headline)
                .padding(.top)
            ForEach(Array(event.responses), id: \.key) { userId, response in
                HStack {
                    Text(eventViewModel.getUserName(for: userId))
                    Spacer()
                    Circle()
                        .fill(colorForResponse(response))
                        .frame(width: 20, height: 20)
                }
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

struct CustomResponseButtonStyle: ButtonStyle {
    let color: Color
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(isSelected ? color : color.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
    }
}
