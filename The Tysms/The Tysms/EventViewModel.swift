import Foundation
import Firebase

class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var userNames: [String: String] = [:]
    private var db = Firestore.firestore()
    
    init() {
        fetchEvents()
        fetchUserNames()
    }
    
    func fetchEvents() {
        print("Fetching events...")
        db.collection("events").order(by: "date").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching events: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No documents found")
                return
            }
            
            print("Found \(documents.count) documents")
            
            self.events = documents.compactMap { queryDocumentSnapshot -> Event? in
                let data = queryDocumentSnapshot.data()
                let id = queryDocumentSnapshot.documentID
                
                guard let title = data["title"] as? String,
                      let dateTimestamp = data["date"] as? Timestamp,
                      let location = data["location"] as? String,
                      let description = data["description"] as? String else {
                    print("Error parsing document \(id): Missing or invalid fields")
                    return nil
                }
                
                let date = dateTimestamp.dateValue()
                let responses = data["responses"] as? [String: String] ?? [:]
                
                return Event(id: id, title: title, date: date, location: location, description: description, responses: responses)
            }
            
            print("Mapped \(self.events.count) events")
        }
    }
    
    func fetchUserNames() {
        print("Fetching user names...")
        db.collection("userRoles").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching user names: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No user documents found")
                return
            }
            
            self.userNames = documents.reduce(into: [:]) { result, document in
                let userId = document.documentID
                let name = document.data()["name"] as? String ?? document.data()["email"] as? String ?? "Unknown User"
                result[userId] = name
            }
            
            print("Fetched \(self.userNames.count) user names")
            self.objectWillChange.send()
        }
    }
    
    func addEvent(title: String, date: Date, location: String, description: String) {
        let newEvent: [String: Any] = [
            "title": title,
            "date": Timestamp(date: date),
            "location": location,
            "description": description,
            "responses": [:]
        ]
        
        db.collection("events").addDocument(data: newEvent) { error in
            if let error = error {
                print("Error adding event: \(error.localizedDescription)")
            } else {
                print("Event added successfully")
            }
        }
    }
    
    func updateEventResponse(eventId: String, userId: String, response: String?) {
        db.collection("events").document(eventId).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                var responses = document.data()?["responses"] as? [String: String] ?? [:]
                
                if let response = response {
                    responses[userId] = response
                } else {
                    responses.removeValue(forKey: userId)
                }
                
                self.db.collection("events").document(eventId).updateData(["responses": responses]) { error in
                    if let error = error {
                        print("Error updating event response: \(error.localizedDescription)")
                    } else {
                        print("Event response updated successfully")
                        self.fetchEvents() // Refresh events after updating
                    }
                }
            }
        }
    }
    
    func deleteEvent(eventId: String) {
        db.collection("events").document(eventId).delete { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error deleting event: \(error.localizedDescription)")
            } else {
                print("Event deleted successfully")
                self.fetchEvents() // Refresh events after deleting
            }
        }
    }
    
    func getUserName(for userId: String) -> String {
        return userNames[userId] ?? "Unknown User"
    }
}
