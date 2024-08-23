//
//  AddFinanceView.swift
//  The Tysms
//
//  Created by Jack Hodgy on 23/08/2024.
//


import SwiftUI

struct AddFinanceView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var date = Date()
    @State private var amount = ""
    @State private var description = ""
    @State private var type = Finance.FinanceType.income
    @State private var category = ""
    
    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                TextField("Description", text: $description)
                Picker("Type", selection: $type) {
                    Text("Income").tag(Finance.FinanceType.income)
                    Text("Expense").tag(Finance.FinanceType.expense)
                }
                TextField("Category", text: $category)
            }
            .navigationTitle("Add Finance")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                if let amountDouble = Double(amount) {
                    viewModel.addFinance(date: date, amount: amountDouble, description: description, type: type, category: category)
                    presentationMode.wrappedValue.dismiss()
                }
            })
        }
    }
}
