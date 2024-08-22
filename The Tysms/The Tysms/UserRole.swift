import Foundation
import FirebaseFirestore

struct UserRole: Identifiable, Codable {
    @DocumentID var id: String?
    var userid: String
    var email: String
    var role: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userid
        case email
        case role
    }
}
