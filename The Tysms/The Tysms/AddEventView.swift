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
                Section(header: Text("Event Details")) {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    TextField("Location", text: $location)
                    TextField("Description", text: $description)
                }
            }
            .navigationTitle("Add Event")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    saveEvent()
                }
            )
        }
    }
    
    private func saveEvent() {
        eventViewModel.addEvent(title: title, date: date, location: location, description: description)
        presentationMode.wrappedValue.dismiss()
    }
}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView(eventViewModel: EventViewModel())
    }
}
