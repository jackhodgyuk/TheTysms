import Firebase
import FirebaseFirestore


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
                let data = queryDocumentSnapshot.data()
                let id = queryDocumentSnapshot.documentID
                guard let date = (data["date"] as? Timestamp)?.dateValue(),
                      let amount = data["amount"] as? Double,
                      let description = data["description"] as? String,
                      let typeRawValue = data["type"] as? String,
                      let type = Finance.FinanceType(rawValue: typeRawValue),
                      let category = data["category"] as? String else {
                    return nil
                }
                return Finance(id: id, date: date, amount: amount, description: description, type: type, category: category)
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
                let data = queryDocumentSnapshot.data()
                let id = queryDocumentSnapshot.documentID
                guard let requesterId = data["requesterId"] as? String,
                      let itemName = data["itemName"] as? String,
                      let itemDescription = data["itemDescription"] as? String,
                      let cost = data["cost"] as? Double,
                      let dateRequested = (data["dateRequested"] as? Timestamp)?.dateValue(),
                      let approvals = data["approvals"] as? [String],
                      let statusRawValue = data["status"] as? String,
                      let status = PurchaseRequest.RequestStatus(rawValue: statusRawValue) else {
                    return nil
                }
                return PurchaseRequest(id: id, requesterId: requesterId, itemName: itemName, itemDescription: itemDescription, cost: cost, dateRequested: dateRequested, approvals: approvals, status: status)
            }
        }
    }
    
    func addFinance(date: Date, amount: Double, description: String, type: Finance.FinanceType, category: String) {
        let newFinance = Finance(id: UUID().uuidString, date: date, amount: amount, description: description, type: type, category: category)
        
        do {
            try db.collection("finances").document(newFinance.id!).setData(from: newFinance)
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
        let newRequest = PurchaseRequest(id: UUID().uuidString,
                                         requesterId: requesterId,
                                         itemName: itemName,
                                         itemDescription: itemDescription,
                                         cost: cost,
                                         dateRequested: Date(),
                                         approvals: [],
                                         status: .pending)
        
        do {
            try db.collection("purchaseRequests").document(newRequest.id!).setData(from: newRequest)
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
