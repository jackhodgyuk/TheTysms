import SwiftUI

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
