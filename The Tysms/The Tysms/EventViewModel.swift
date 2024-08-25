import Foundation
import Firebase
import FirebaseFirestore

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
            sendEventNotification(eventTitle: event.title)
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
    
    func sendEventNotification(eventTitle: String) {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if let token = document.data()["fcmToken"] as? String {
                        self.sendNotificationToDevice(token: token, title: "New Event", body: "Can You Attend This Gig/Practice?", eventTitle: eventTitle)
                    }
                }
            }
        }
    }
    
    func sendNotificationToDevice(token: String, title: String, body: String, eventTitle: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["event" : eventTitle]]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=YOUR_SERVER_KEY", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
