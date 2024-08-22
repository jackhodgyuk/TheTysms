//
//  Event.swift
//  The Tysms
//
//  Created by Jack Hodgy on 22/08/2024.
//


import Foundation
import FirebaseFirestore
import SwiftUI

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
        guard let userId = Auth.auth().currentUser?.uid, let eventId = event.id else { return }
        
        let db = Firestore.firestore()
        db.collection("events").document(eventId).updateData([
            "attendees": FieldValue.arrayUnion([
                ["userId": userId, "status": status.rawValue, "note": note ?? ""]
            ])
        ])
    }
}

struct EventListView: View {
    @StateObject private var viewModel = EventViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.events) { event in
                NavigationLink(destination: EventDetailView(event: event)) {
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.headline)
                        Text(event.date, style: .date)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Upcoming Events")
            .onAppear {
                viewModel.fetchEvents()
            }
        }
    }
}

struct EventDetailView: View {
    @StateObject private var viewModel = EventViewModel()
    let event: Event
    @State private var attendanceStatus: Event.Attendee.AttendanceStatus = .maybe
    @State private var attendanceNote: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Event Details")) {
                Text(event.title)
                Text(event.date, style: .date)
                Text(event.type.rawValue.capitalized)
            }
            
            Section(header: Text("Your Attendance")) {
                Picker("Status", selection: $attendanceStatus) {
                    Text("Yes").tag(Event.Attendee.AttendanceStatus.yes)
                    Text("No").tag(Event.Attendee.AttendanceStatus.no)
                    Text("Maybe").tag(Event.Attendee.AttendanceStatus.maybe)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                TextField("Notes", text: $attendanceNote)
            }
            
            Button("Update Attendance") {
                viewModel.updateAttendance(for: event, status: attendanceStatus, note: attendanceNote)
            }
        }
        .navigationTitle(event.title)
    }
}
