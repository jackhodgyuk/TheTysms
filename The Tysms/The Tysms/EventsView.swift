import SwiftUI

struct EventsView: View {
    @ObservedObject var eventViewModel: EventViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddEvent = false
    
    var body: some View {
        NavigationView {
            List(eventViewModel.events) { event in
                NavigationLink(destination: EventDetailView(eventViewModel: eventViewModel, event: event)) {
                    EventRow(event: event)
                }
            }
            .navigationBarTitle("Events")
            .navigationBarItems(trailing: addButton)
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(eventViewModel: eventViewModel)
            }
        }
        .onAppear {
            eventViewModel.fetchEvents()
        }
    }
    
    private var addButton: some View {
        Button(action: {
            if authViewModel.isAdminOrManager() {
                showingAddEvent = true
            }
        }) {
            Image(systemName: "plus")
        }
        .disabled(!authViewModel.isAdminOrManager())
    }
}

struct EventRow: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(event.title)
                .font(.headline)
            Text(event.date, style: .date)
                .font(.subheadline)
            Text(event.location)
                .font(.subheadline)
        }
    }
}
