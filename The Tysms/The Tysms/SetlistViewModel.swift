import Foundation
import Firebase

class SetlistViewModel: ObservableObject {
    @Published var songs: [Song] = []
    private var db = Firestore.firestore()
    
    func fetchSongs() {
        db.collection("setlist").order(by: "order").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            
            self.songs = documents.compactMap { queryDocumentSnapshot -> Song? in
                let data = queryDocumentSnapshot.data()
                let title = data["title"] as? String ?? ""
                return Song(id: queryDocumentSnapshot.documentID, title: title)
            }
        }
    }
    
    func addSong(title: String) {
        let newSong: [String: Any] = ["title": title, "order": songs.count]
        db.collection("setlist").addDocument(data: newSong) { error in
            if let error = error {
                print("Error adding song: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteSong(at offsets: IndexSet) {
        let songsToDelete = offsets.map { self.songs[$0] }
        songsToDelete.forEach { song in
            db.collection("setlist").document(song.id).delete { error in
                if let error = error {
                    print("Error deleting song: \(error.localizedDescription)")
                }
            }
        }
        songs.remove(atOffsets: offsets)
        updateOrder()
    }
    
    func moveSong(from source: IndexSet, to destination: Int) {
        songs.move(fromOffsets: source, toOffset: destination)
        updateOrder()
    }
    
    private func updateOrder() {
        for (index, song) in songs.enumerated() {
            db.collection("setlist").document(song.id).updateData(["order": index]) { error in
                if let error = error {
                    print("Error updating song order: \(error.localizedDescription)")
                }
            }
        }
    }
}
