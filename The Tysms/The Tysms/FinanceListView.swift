//
//  FinanceListView.swift
//  The Tysms
//
//  Created by Jack Hodgy on 23/08/2024.
//


import SwiftUI

struct FinanceListView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @State private var showingAddFinance = false

    var body: some View {
        List {
            ForEach(viewModel.finances) { finance in
                FinanceRow(finance: finance)
            }
            .onDelete(perform: deleteFinance)
        }
        .navigationBarItems(trailing: Button(action: { showingAddFinance = true }) {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $showingAddFinance) {
            AddFinanceView(viewModel: viewModel)
        }
    }

    private func deleteFinance(at offsets: IndexSet) {
        offsets.forEach { index in
            if let id = viewModel.finances[index].id {
                viewModel.deleteFinance(financeId: id)
            }
        }
    }
}

struct FinanceRow: View {
    let finance: Finance

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(finance.description)
                    .font(.headline)
                Text(finance.category)
                    .font(.subheadline)
            }
            Spacer()
            Text(String(format: "%.2f", finance.amount))
                .foregroundColor(finance.type == .income ? .green : .red)
        }
    }
}
