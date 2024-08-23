import SwiftUI
import FirebaseAuth

struct EventDetailView: View {
    @ObservedObject var eventViewModel: EventViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    let event: Event
    @State private var userResponse: String = ""
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(event.title)
                    .font(.title)
                Text(event.date, style: .date)
                Text(event.location)
                Text(event.description)
                
                Divider()
                
                Text("Responses:")
                    .font(.headline)
                
                if authViewModel.currentUser?.role == "admin" {
                    ForEach(Array(event.responses), id: \.key) { userId, response in
                        HStack {
                            Text(authViewModel.getUserName(for: userId) ?? userId)
                            Spacer()
                            Text(response)
                            responseIcon(for: response)
                        }
                    }
                }
                
                HStack {
                    responseButton(response: "Yes", color: .green)
                    responseButton(response: "Maybe", color: .yellow)
                    responseButton(response: "No", color: .red)
                }
                .padding(.top)
            }
            .padding()
        }
        .navigationBarItems(trailing: Group {
            if authViewModel.currentUser?.role == "admin" {
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                }
            }
        })
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Event"),
                message: Text("Are you sure you want to delete this event?"),
                primaryButton: .destructive(Text("Delete")) {
                    eventViewModel.deleteEvent(event) { success in
                        if success {
                            print("Event deleted successfully")
                        } else {
                            print("Failed to delete event")
                        }
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            if let userId = Auth.auth().currentUser?.uid {
                userResponse = event.responses[userId] ?? ""
            }
        }
    }
    
    private func responseButton(response: String, color: Color) -> some View {
        Button(action: {
            updateResponse(response)
        }) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 60, height: 60)
                Text(response)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
        }
    }
    
    private func responseIcon(for response: String) -> some View {
        let iconName: String
        let color: Color
        switch response {
        case "Yes":
            iconName = "checkmark.circle.fill"
            color = .green
        case "Maybe":
            iconName = "questionmark.circle.fill"
            color = .yellow
        case "No":
            iconName = "xmark.circle.fill"
            color = .red
        default:
            iconName = "circle"
            color = .gray
        }
        return Image(systemName: iconName)
            .foregroundColor(color)
    }
    
    private func updateResponse(_ newResponse: String) {
        if let userId = Auth.auth().currentUser?.uid {
            var updatedEvent = event
            updatedEvent.responses[userId] = newResponse
            eventViewModel.updateEvent(updatedEvent) { success in
                if success {
                    print("Response updated successfully")
                    userResponse = newResponse
                } else {
                    print("Failed to update response")
                }
            }
        }
    }
}
