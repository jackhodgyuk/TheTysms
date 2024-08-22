import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var date: Date
    var type: EventType
    var attendees: [Attendee]
    var notes: String?
    
    enum EventType: String, Codable {
        case gig, practice, meeting
    }
    
    struct Attendee: Codable {
        var userId: String
        var status: AttendanceStatus
        var note: String?
        
        enum AttendanceStatus: String, Codable {
            case yes, no, maybe
        }
    }
}

class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    
    func fetchEvents() {
        let db = Firestore.firestore()
        db.collection("events").order(by: "date").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error fetching events: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.events = documents.compactMap { try? $0.data(as: Event.self) }
        }
    }
    
    func updateAttendance(for event: Event, status: Event.Attendee.AttendanceStatus, note: String?) {
        guard let userId = FirebaseAuth.Auth.auth().currentUser?.uid, let eventId = event.id else { return }
        
        let db = Firestore.firestore()
        db.collection("events").document(eventId).updateData([
            "attendees": FieldValue.arrayUnion([
                ["userId": userId, "status": status.rawValue, "note": note ?? ""]
            ])
        ])
    }
}
