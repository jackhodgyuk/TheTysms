//
//  PurchaseRequestDetailView.swift
//  The Tysms
//
//  Created by Jack Hodgy on 23/08/2024.
//


import SwiftUI

struct PurchaseRequestDetailView: View {
    let request: PurchaseRequest
    @ObservedObject var viewModel: FinanceViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(request.itemName)
                .font(.title)
            Text(request.itemDescription)
                .font(.body)
            Text("Cost: $\(String(format: "%.2f", request.cost))")
                .font(.headline)
            Text("Status: \(request.status.rawValue.capitalized)")
                .font(.headline)
            Text("Approvals: \(request.approvals.count)/2")
                .font(.subheadline)
            
            if request.status == .pending {
                if !request.approvals.contains(authViewModel.currentUser?.uid ?? "") {
                    Button("Approve") {
                        if let userId = authViewModel.currentUser?.uid, let requestId = request.id {
                            viewModel.approvePurchaseRequest(requestId: requestId, approverId: userId)
                        }
                    }
                }
                
                if authViewModel.isManager() {
                    HStack {
                        Button("Approve Purchase") {
                            if let requestId = request.id {
                                viewModel.finalizeRequest(requestId: requestId, approved: true)
                            }
                        }
                        .disabled(request.approvals.count < 2)
                        
                        Button("Reject Purchase") {
                            if let requestId = request.id {
                                viewModel.finalizeRequest(requestId: requestId, approved: false)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Request Details")
    }
}
