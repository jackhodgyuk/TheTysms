import SwiftUI

struct SetlistView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var setlistViewModel = SetlistViewModel()
    @State private var isEditing = false
    @State private var newSongTitle = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(setlistViewModel.songs) { song in
                    Text(song.title)
                }
                .onDelete(perform: setlistViewModel.deleteSong)
                .onMove(perform: setlistViewModel.moveSong)
                
                if isEditing {
                    HStack {
                        TextField("New song", text: $newSongTitle)
                        Button(action: addSong) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
            }
            .navigationTitle("Setlist")
            .navigationBarItems(trailing: Group {
                if authViewModel.isManager() || authViewModel.isAdmin() {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                    }
                }
            })
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
        }
        .onAppear {
            setlistViewModel.fetchSongs()
        }
    }
    
    private func addSong() {
        setlistViewModel.addSong(title: newSongTitle)
        newSongTitle = ""
    }
}
