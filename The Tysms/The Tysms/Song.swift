import Foundation

struct Song: Identifiable, Equatable {
    let id: String
    var title: String
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title
    }
}
