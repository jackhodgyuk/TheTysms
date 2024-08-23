//
//  FinanceViewModel.swift
//  The Tysms
//
//  Created by Jack Hodgy on 23/08/2024.
//


import Foundation
import Firebase

class FinanceViewModel: ObservableObject {
    @Published var finances: [Finance] = []
    @Published var purchaseRequests: [PurchaseRequest] = []
    private var db = Firestore.firestore()
    
    init() {
        fetchFinances()
        fetchPurchaseRequests()
    }
    
    func fetchFinances() {
        db.collection("finances").order(by: "date", descending: true).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No finance documents")
                return
            }
            
            self.finances = documents.compactMap { queryDocumentSnapshot -> Finance? in
                return try? queryDocumentSnapshot.data(as: Finance.self)
            }
        }
    }
    
    func fetchPurchaseRequests() {
        db.collection("purchaseRequests").order(by: "dateRequested", descending: true).addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No purchase request documents")
                return
            }
            
            self.purchaseRequests = documents.compactMap { queryDocumentSnapshot -> PurchaseRequest? in
                return try? queryDocumentSnapshot.data(as: PurchaseRequest.self)
            }
        }
    }
    
    func addFinance(date: Date, amount: Double, description: String, type: Finance.FinanceType, category: String) {
        let newFinance = Finance(date: date, amount: amount, description: description, type: type, category: category)
        
        do {
            _ = try db.collection("finances").addDocument(from: newFinance)
        } catch {
            print("Error adding finance: \(error)")
        }
    }
    
    func deleteFinance(financeId: String) {
        db.collection("finances").document(financeId).delete { error in
            if let error = error {
                print("Error deleting finance: \(error)")
            }
        }
    }
    
    func submitPurchaseRequest(itemName: String, itemDescription: String, cost: Double, requesterId: String) {
        let newRequest = PurchaseRequest(requesterId: requesterId,
                                         itemName: itemName,
                                         itemDescription: itemDescription,
                                         cost: cost,
                                         dateRequested: Date(),
                                         approvals: [],
                                         status: .pending)
        
        do {
            _ = try db.collection("purchaseRequests").addDocument(from: newRequest)
        } catch {
            print("Error adding purchase request: \(error)")
        }
    }
    
    func approvePurchaseRequest(requestId: String, approverId: String) {
        db.collection("purchaseRequests").document(requestId).updateData([
            "approvals": FieldValue.arrayUnion([approverId])
        ]) { error in
            if let error = error {
                print("Error approving request: \(error)")
            }
        }
    }
    
    func finalizeRequest(requestId: String, approved: Bool) {
        db.collection("purchaseRequests").document(requestId).updateData([
            "status": approved ? PurchaseRequest.RequestStatus.approved.rawValue : PurchaseRequest.RequestStatus.rejected.rawValue
        ]) { error in
            if let error = error {
                print("Error finalizing request: \(error)")
            }
        }
    }
}
