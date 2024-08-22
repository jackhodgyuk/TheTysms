//
//  AddEventView.swift
//  The Tysms
//
//  Created by Jack Hodgy on 22/08/2024.
//


import SwiftUI

struct AddEventView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var eventViewModel: EventViewModel
    @State private var title = ""
    @State private var date = Date()
    @State private var location = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                TextField("Location", text: $location)
                TextEditor(text: $description)
                    .frame(height: 100)
            }
            .navigationTitle("Add Event")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                let newEvent = Event(title: title, date: date, location: location, description: description)
                eventViewModel.addEvent(newEvent)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
