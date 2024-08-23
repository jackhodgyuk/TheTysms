//
//  FinancesView.swift
//  The Tysms
//
//  Created by Jack Hodgy on 23/08/2024.
//


import SwiftUI

struct FinancesView: View {
    @StateObject private var viewModel = FinanceViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingAddFinance = false
    @State private var showingAddRequest = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("", selection: $selectedTab) {
                    Text("Finances").tag(0)
                    Text("Purchase Requests").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedTab == 0 {
                    FinanceListView(viewModel: viewModel, showingAddFinance: $showingAddFinance)
                } else {
                    PurchaseRequestListView(viewModel: viewModel, showingAddRequest: $showingAddRequest)
                }
            }
            .navigationTitle("Finances")
            .navigationBarItems(trailing: Button(action: {
                if selectedTab == 0 {
                    showingAddFinance = true
                } else {
                    showingAddRequest = true
                }
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddFinance) {
                AddFinanceView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAddRequest) {
                AddPurchaseRequestView(viewModel: viewModel)
            }
        }
    }
}

struct FinanceListView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @Binding var showingAddFinance: Bool
    
    var body: some View {
        List {
            ForEach(viewModel.finances) { finance in
                FinanceRow(finance: finance)
            }
            .onDelete(perform: deleteFinance)
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

struct PurchaseRequestListView: View {
    @ObservedObject var viewModel: FinanceViewModel
    @Binding var showingAddRequest: Bool
    
    var body: some View {
        List {
            ForEach(viewModel.purchaseRequests) { request in
                NavigationLink(destination: PurchaseRequestDetailView(request: request, viewModel: viewModel)) {
                    PurchaseRequestRow(request: request)
                }
            }
        }
    }
}

struct PurchaseRequestRow: View {
    let request: PurchaseRequest
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(request.itemName)
                .font(.headline)
            Text("Cost: $\(String(format: "%.2f", request.cost))")
                .font(.subheadline)
            Text("Status: \(request.status.rawValue.capitalized)")
                .font(.subheadline)
        }
    }
}
