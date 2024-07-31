import SwiftUI

struct NoteDetailView: View {
    var note: Note
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(note.content)
                .padding()
            Spacer()
        }
        .navigationTitle(note.title)
    }
}
