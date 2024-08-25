import SwiftUI

struct SetlistView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var setlistViewModel = SetlistViewModel()
    @State private var isEditing = false
    @State private var newSongTitle = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    List {
                        ForEach(Array(setlistViewModel.songs.enumerated()), id: \.element.id) { index, song in
                            HStack {
                                Text("\(index + 1).")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .frame(width: 30, alignment: .leading)
                                
                                Text(song.title)
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, design: .monospaced))
                            }
                            .listRowBackground(Color.black)
                        }
                        .onDelete(perform: isEditing ? setlistViewModel.deleteSong : nil)
                        .onMove(perform: isEditing ? setlistViewModel.moveSong : nil)
                        
                        if isEditing {
                            HStack {
                                TextField("New song", text: $newSongTitle)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .foregroundColor(.black)
                                
                                Button(action: addSong) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.yellow)
                                }
                            }
                            .listRowBackground(Color.black)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Setlist")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Group {
                if authViewModel.isManager() || authViewModel.isAdmin() {
                    Button(isEditing ? "Done" : "Edit") {
                        isEditing.toggle()
                    }
                    .foregroundColor(.yellow)
                }
            })
            .environment(\.editMode, .constant(isEditing ? .active : .inactive))
        }
        .onAppear {
            setlistViewModel.fetchSongs()
            configureTabBar()
        }
    }
    
    private func addSong() {
        setlistViewModel.addSong(title: newSongTitle)
        newSongTitle = ""
    }
    
    private func configureTabBar() {
        UITabBar.appearance().backgroundColor = UIColor.white.withAlphaComponent(0.2)
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.7)
        UITabBar.appearance().tintColor = .yellow
    }
}
