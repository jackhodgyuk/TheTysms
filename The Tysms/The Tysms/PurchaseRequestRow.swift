//
//  PurchaseRequestRow.swift
//  The Tysms
//
//  Created by Jack Hodgy on 23/08/2024.
//


import SwiftUI

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

#Preview {
    PurchaseRequestRow(request: PurchaseRequest(id: "1", requesterId: "user1", itemName: "Test Item", itemDescription: "Test Description", cost: 100.0, dateRequested: Date(), approvals: [], status: .pending))
}
