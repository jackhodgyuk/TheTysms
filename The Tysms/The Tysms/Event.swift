import Foundation
import FirebaseFirestore

struct Event: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var date: Date
    var location: String
    var description: String
    var responses: [String: String] = [:] // [userId: response]
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case date
        case location
        case description
        case responses
    }
}
