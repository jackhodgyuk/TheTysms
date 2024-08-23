import SwiftUI

struct EventsView: View {
    @ObservedObject var eventViewModel: EventViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddEvent = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(eventViewModel.events) { event in
                    NavigationLink(destination: EventDetailView(eventViewModel: eventViewModel, event: event)) {
                        EventRow(event: event)
                    }
                }
            }
            .navigationTitle("Events")
            .navigationBarItems(trailing: Button(action: { showingAddEvent = true }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddEvent) {
                AddEventView(eventViewModel: eventViewModel)
            }
        }
    }
}

struct EventRow: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(event.title)
                .font(.headline)
            Text(event.date.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView(eventViewModel: EventViewModel())
            .environmentObject(AuthViewModel())
    }
}
