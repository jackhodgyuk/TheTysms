import Foundation

struct PurchaseRequest: Identifiable, Codable {
    var id: String?
    let requesterId: String
    let itemName: String
    let itemDescription: String
    let cost: Double
    let dateRequested: Date
    var approvals: [String]
    var status: RequestStatus
    
    enum RequestStatus: String, Codable {
        case pending
        case approved
        case rejected
    }
}
