import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: NotesViewModel
    @State private var searchText = ""
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return viewModel.notes
        } else {
            return viewModel.notes.filter { $0.title.localizedCaseInsensitiveContains(searchText) || $0.content.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack {
            TextField("Search...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Search") {
                // Trigger search action
            }
            .padding()
            
            List {
                ForEach(filteredNotes) { note in
                    NavigationLink(destination: NoteDetailView(note: note)) {
                        Text(note.title)
                    }
                }
            }
        }
        .navigationTitle("Search Notes")
    }
}

