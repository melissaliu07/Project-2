import SwiftUI
import EventKit

struct WriteNotes: View {
    @StateObject private var notesViewModel = NotesViewModel()
    @State private var showingNoteEditor = false
    @State private var noteToEdit: Note?
    @State private var showingCalendar = false
    
    var body: some View {
        TabView {  // Added TabView to include multiple tabs
            NavigationView {
                VStack {
                    Button("Write Down Notes") {
                        noteToEdit = nil
                        showingNoteEditor = true
                    }
                    .padding()
                    
                    List {
                        ForEach(notesViewModel.notes) { note in
                            HStack {
                                NavigationLink(destination: NoteDetailView(note: note)) {
                                    Text(note.title)
                                }
                                Spacer()
                                Button(action: {
                                    noteToEdit = note
                                    showingNoteEditor = true
                                }) {
                                    Text("Edit")
                                        .foregroundColor(.blue)
                                }
                                Button(action: {
                                    notesViewModel.delete(note: note)
                                }) {
                                    Text("Delete")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingCalendar = true
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Calendar")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.5, green: 0.7, blue: 0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }
                .navigationTitle("Your Notes")
                .sheet(isPresented: $showingNoteEditor) {
                    NoteEditorView(viewModel: notesViewModel, note: noteToEdit)
                }
                .sheet(isPresented: $showingCalendar) {
                    CalendarView()
                }
            }
            .tabItem {  // Added tab item for the home tab
                Label("Home", systemImage: "house")
            }

            SearchView(viewModel: notesViewModel)  // Added SearchView as a new tab
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
    }
}

