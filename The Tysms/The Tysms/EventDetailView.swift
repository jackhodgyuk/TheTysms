import SwiftUI
import FirebaseAuth

struct EventDetailView: View {
    @ObservedObject var eventViewModel: EventViewModel
    let event: Event
    @State private var userResponse: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(event.title)
                    .font(.title)
                Text(event.date, style: .date)
                Text(event.location)
                Text(event.description)
                
                Divider()
                
                Text("Your Response:")
                    .font(.headline)
                
                Picker("Your Response", selection: $userResponse) {
                    Text("Not Responded").tag("")
                    Text("Going").tag("Going")
                    Text("Not Going").tag("Not Going")
                    Text("Maybe").tag("Maybe")
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: userResponse) { newValue in
                    updateResponse(newValue)
                }
                
                Divider()
                
                Text("All Responses:")
                    .font(.headline)
                
                ForEach(Array(event.responses), id: \.key) { userId, response in
                    HStack {
                        Text(userId)
                        Spacer()
                        Text(response)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            if let userId = Auth.auth().currentUser?.uid {
                userResponse = event.responses[userId] ?? ""
            }
        }
    }
    
    private func updateResponse(_ newResponse: String) {
        if let userId = Auth.auth().currentUser?.uid {
            var updatedEvent = event
            updatedEvent.responses[userId] = newResponse
            eventViewModel.updateEvent(updatedEvent) { success in
                if success {
                    print("Response updated successfully")
                } else {
                    print("Failed to update response")
                }
            }
        }
    }
}
