import Foundation
import Firebase

class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    private var db = Firestore.firestore()
    
    func fetchEvents() {
        db.collection("events").order(by: "date").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.events = documents.compactMap { queryDocumentSnapshot -> Event? in
                return try? queryDocumentSnapshot.data(as: Event.self)
            }
        }
    }
    
    func addEvent(_ event: Event, completion: @escaping (Bool) -> Void) {
        do {
            let _ = try db.collection("events").addDocument(from: event)
            completion(true)
        } catch {
            print("Error adding event: \(error)")
            completion(false)
        }
    }
    
    func updateEvent(_ event: Event, completion: @escaping (Bool) -> Void) {
        if let id = event.id {
            do {
                try db.collection("events").document(id).setData(from: event)
                completion(true)
            } catch {
                print("Error updating event: \(error)")
                completion(false)
            }
        }
    }
    
    func deleteEvent(_ event: Event, completion: @escaping (Bool) -> Void) {
        if let id = event.id {
            db.collection("events").document(id).delete { error in
                if let error = error {
                    print("Error removing event: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
}
