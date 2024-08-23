import SwiftUI

struct AddEventView: View {
    @ObservedObject var eventViewModel: EventViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var date = Date()
    @State private var location = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Location", text: $location)
                TextField("Description", text: $description)
            }
            .navigationBarTitle("Add Event")
            .navigationBarItems(leading: cancelButton, trailing: addButton)
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var addButton: some View {
        Button("Add") {
            let newEvent = Event(title: title, date: date, location: location, description: description)
            eventViewModel.addEvent(newEvent) { success in
                if success {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
