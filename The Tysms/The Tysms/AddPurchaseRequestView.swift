//
//  AddPurchaseRequestView.swift
//  The Tysms
//
//  Created by Jack Hodgy on 23/08/2024.
//


import SwiftUI

struct AddPurchaseRequestView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var itemName = ""
    @State private var itemDescription = ""
    @State private var cost = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Item Name", text: $itemName)
                TextField("Item Description", text: $itemDescription)
                TextField("Cost", text: $cost)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("New Purchase Request")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Submit") {
                if let costDouble = Double(cost), let userId = authViewModel.currentUser?.uid {
                    viewModel.submitPurchaseRequest(itemName: itemName, itemDescription: itemDescription, cost: costDouble, requesterId: userId)
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
    }
}
