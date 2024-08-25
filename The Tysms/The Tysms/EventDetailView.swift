import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EventDetailView: View {
    @ObservedObject var eventViewModel: EventViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    let event: Event
    @State private var userResponse: String = ""
    @State private var userNames: [String: String] = [:]

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
                
                HStack {
                    responseButton(response: "Yes", color: .green)
                    responseButton(response: "Maybe", color: .yellow)
                    responseButton(response: "No", color: .red)
                }
                .padding(.vertical)
                
                if let userId = Auth.auth().currentUser?.uid, let response = event.responses[userId] {
                    Divider()
                    
                    Text("Your Current Response:")
                        .font(.headline)
                    
                    HStack {
                        Text(authViewModel.currentUser?.displayName ?? "You")
                        Spacer()
                        Text(response)
                        responseIcon(for: response)
                    }
                }
                
                if authViewModel.isAdminOrManager() {
                    Divider()
                    
                    Text("All Responses:")
                        .font(.headline)
                    
                    ForEach(Array(event.responses), id: \.key) { userId, response in
                        HStack {
                            Text(userNames[userId] ?? "Loading...")
                            Spacer()
                            Text(response)
                            responseIcon(for: response)
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            if let userId = Auth.auth().currentUser?.uid {
                userResponse = event.responses[userId] ?? ""
            }
            if authViewModel.isAdminOrManager() {
                fetchUserNames()
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
        let color: Color
        switch response {
        case "Yes":
            color = .green
        case "Maybe":
            color = .yellow
        case "No":
            color = .red
        default:
            color = .gray
        }
        return Circle()
            .fill(color)
            .frame(width: 20, height: 20)
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
    
    private func fetchUserNames() {
        let db = Firestore.firestore()
        for userId in event.responses.keys {
            db.collection("userRoles").document(userId).getDocument { (document, error) in
                if let document = document, document.exists {
                    if let name = document.data()?["name"] as? String {
                        DispatchQueue.main.async {
                            self.userNames[userId] = name
                        }
                    }
                }
            }
        }
    }
}
