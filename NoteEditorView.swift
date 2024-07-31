import SwiftUI

struct NoteEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: NotesViewModel
    
    @State private var noteTitle = ""
    @State private var noteContent = ""
    var note: Note?
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Title", text: $noteTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextEditor(text: $noteContent)
                    .border(Color.gray, width: 1)
                    .padding()
                
                Spacer()
            }
            .navigationBarTitle(note == nil ? "New Note" : "Edit Note", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                let newNote = Note(
                    id: note?.id ?? UUID(),
                    title: noteTitle,
                    content: noteContent
                )
                
                if note == nil {
                    viewModel.add(note: newNote)
                } else {
                    viewModel.update(note: newNote)
                }
                
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                if let note = note {
                    noteTitle = note.title
                    noteContent = note.content
                }
            }
        }
    }
}
