//
//  EventDetailView.swift
//  The Tysms
//
//  Created by Jack Hodgy on 22/08/2024.
//


import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var eventViewModel: EventViewModel
    let event: Event
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(event.title)
                    .font(.title)
                Text(event.date, style: .date)
                    .font(.subheadline)
                Text(event.location)
                    .font(.subheadline)
                Text(event.description)
                    .padding(.top)
                
                if authViewModel.isManager() || authViewModel.isAdmin() {
                    ResponseList(event: event)
                } else {
                    ResponseButtons(event: event, eventViewModel: eventViewModel)
                }
            }
            .padding()
        }
        .navigationTitle("Event Details")
    }
}

struct ResponseButtons: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    let event: Event
    @ObservedObject var eventViewModel: EventViewModel
    
    var body: some View {
        HStack {
            Button("Yes") { updateResponse("yes") }
                .buttonStyle(ResponseButtonStyle(color: .green, isSelected: isSelected("yes")))
            Button("Maybe") { updateResponse("maybe") }
                .buttonStyle(ResponseButtonStyle(color: .yellow, isSelected: isSelected("maybe")))
            Button("No") { updateResponse("no") }
                .buttonStyle(ResponseButtonStyle(color: .red, isSelected: isSelected("no")))
        }
    }
    
    func updateResponse(_ response: String) {
        guard let userId = authViewModel.currentUser?.uid, let eventId = event.id else { return }
        eventViewModel.updateEventResponse(eventId: eventId, userId: userId, response: response)
    }
    
    func isSelected(_ response: String) -> Bool {
        guard let userId = authViewModel.currentUser?.uid else { return false }
        return event.responses[userId] == response
    }
}

struct ResponseList: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Responses")
                .font(.headline)
                .padding(.top)
            ForEach(Array(event.responses), id: \.key) { userId, response in
                HStack {
                    Text(userId) // You might want to fetch and display user names instead
                    Spacer()
                    Circle()
                        .fill(colorForResponse(response))
                        .frame(width: 20, height: 20)
                }
            }
        }
    }
    
    func colorForResponse(_ response: String) -> Color {
        switch response {
        case "yes":
            return .green
        case "maybe":
            return .yellow
        case "no":
            return .red
        default:
            return .gray
        }
    }
}

struct ResponseButtonStyle: ButtonStyle {
    let color: Color
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(isSelected ? color : color.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
    }
}
