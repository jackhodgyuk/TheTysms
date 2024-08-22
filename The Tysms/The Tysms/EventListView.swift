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
