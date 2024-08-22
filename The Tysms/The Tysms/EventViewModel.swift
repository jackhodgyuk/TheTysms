//
//  EventViewModel.swift
//  The Tysms
//
//  Created by Jack Hodgy on 22/08/2024.
//


import Foundation
import Firebase
import FirebaseFirestore

class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    private var db = Firestore.firestore()
    
    init() {
        fetchEvents()
    }
    
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
    
    func addEvent(_ event: Event) {
        do {
            let _ = try db.collection("events").addDocument(from: event)
        } catch {
            print("Error adding event: \(error)")
        }
    }
    
    func updateEventResponse(eventId: String, userId: String, response: String) {
        db.collection("events").document(eventId).updateData([
            "responses.\(userId)": response
        ]) { error in
            if let error = error {
                print("Error updating event response: \(error)")
            }
        }
    }
}
