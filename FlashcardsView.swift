//
//  FlashcardsView.swift
//  study-sage
//
//  Created by csuftitan on 7/30/24.
//

import Foundation
import SwiftUI

// Flashcard model
struct Flashcard: Identifiable, Codable {
    var id = UUID()
    var title: String
    let description: String
}

// FlashcardStore to manage flashcards
class FlashcardStore: ObservableObject {
    @Published var flashcards: [Flashcard] = []
    
    init() {
        loadFlashcards()
    }
    
    func saveFlashcards() {
        if let encoded = try? JSONEncoder().encode(flashcards) {
            UserDefaults.standard.set(encoded, forKey: "SavedFlashcards")
        }
    }
    
    func loadFlashcards() {
        if let savedFlashcards = UserDefaults.standard.data(forKey: "SavedFlashcards") {
            if let decodedFlashcards = try? JSONDecoder().decode([Flashcard].self, from: savedFlashcards) {
                flashcards = decodedFlashcards
            }
        }
    }
    
    func removeFlashcard(at index: Int) {
        flashcards.remove(at: index)
        saveFlashcards()
    }
    
    func shuffleFlashcards() {
        flashcards.shuffle()
        saveFlashcards()
    }
}

// Dictionary API related structures
struct DictionaryEntry: Codable {
    let word: String
    let meanings: [Meaning]
}

struct Meaning: Codable {
    let partOfSpeech: String
    let definitions: [Definition]
}

struct Definition: Codable {
    let definition: String
}

// Dictionary API Service
class DictionaryAPIService {
    func fetchDefinition(for word: String, completion: @escaping (Result<[DictionaryEntry], Error>) -> Void) {
        let urlString = "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let entries = try JSONDecoder().decode([DictionaryEntry].self, from: data)
                completion(.success(entries))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

// ViewModel for ContentView
class FlashcardViewModel: ObservableObject {
    @Published var flashcard: Flashcard
    @Published var isLoading = false
    private let apiService = DictionaryAPIService()
    
    init(flashcard: Flashcard) {
        self.flashcard = flashcard
    }
    
    func fetchDefinition(completion: @escaping (String) -> Void) {
        guard !flashcard.title.isEmpty else {
            completion("Please enter a word in the title field.")
            return
        }
        
        isLoading = true
        apiService.fetchDefinition(for: flashcard.title) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let entries):
                    if let firstDefinition = entries.first?.meanings.first?.definitions.first?.definition {
                        completion(firstDefinition)
                    } else {
                        completion("No definition found.")
                    }
                case .failure(let error):
                    completion("Error: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct Content2View: View {
    @ObservedObject var flashcardStore: FlashcardStore
    @State private var title: String = ""
    @State private var description: String = ""
    @StateObject private var viewModel: FlashcardViewModel
    
    let sageGreen = Color(red: 0.5, green: 0.7, blue: 0.6)
    
    init(flashcardStore: FlashcardStore) {
        self.flashcardStore = flashcardStore
        let dummyFlashcard = Flashcard(title: "", description: "")
        _viewModel = StateObject(wrappedValue: FlashcardViewModel(flashcard: dummyFlashcard))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter title", text: $title)
                        .onChange(of: title) { newValue in
                            self.viewModel.flashcard.title = newValue
                        }
                }
                
                Section(header: Text("Description")) {
                    TextEditor(text: $description)
                        .frame(height: 360)
                }
            }
            .listRowBackground(Color.clear)
            
            VStack(spacing: 15) {
                Button(action: {
                    viewModel.fetchDefinition { definition in
                        description = definition
                    }
                }) {
                    HStack {
                        Text("Get Definition")
                        if viewModel.isLoading {
                            ProgressView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(sageGreen)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isLoading || title.isEmpty)
                
                Button(action: addFlashcard) {
                    Text("Add Flashcard")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(sageGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(title.isEmpty || description.isEmpty)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Add Flashcard")
    }
    
    func addFlashcard() {
        guard !title.isEmpty && !description.isEmpty else { return }
        let newFlashcard = Flashcard(title: title, description: description)
        flashcardStore.flashcards.append(newFlashcard)
        flashcardStore.saveFlashcards()
        title = ""
        description = ""
    }
}

struct FlashcardsDisplayView: View {
    @ObservedObject var flashcardStore: FlashcardStore
    @State private var currentIndex = 0
    @State private var offset: CGSize = .zero
    @State private var showingList = false
    
    let sageGreen = Color(red: 0.5, green: 0.7, blue: 0.6)
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { showingList = true }) {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.blue)
                }
                .padding()
            }
            
            ZStack {
                ForEach(flashcardStore.flashcards.indices, id: \.self) { index in
                    FlashcardView(flashcard: flashcardStore.flashcards[index])
                        .opacity(index == currentIndex ? 1 : 0)
                        .offset(index == currentIndex ? offset : .zero)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    if index == currentIndex {
                                        self.offset = gesture.translation
                                    }
                                }
                                .onEnded { _ in
                                    if self.offset.height < -100 {
                                        withAnimation {
                                            flashcardStore.removeFlashcard(at: currentIndex)
                                            if currentIndex >= flashcardStore.flashcards.count {
                                                currentIndex = max(flashcardStore.flashcards.count - 1, 0)
                                            }
                                        }
                                    } else if self.offset.width < -50 {
                                        withAnimation {
                                            self.currentIndex = min(self.currentIndex + 1, flashcardStore.flashcards.count - 1)
                                        }
                                    }
                                    withAnimation {
                                        self.offset = .zero
                                    }
                                }
                        )
                }
            }
            .frame(width: 300, height: 200)
            
            Text("Swipe up to discard, left to move to next card")
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
            
            HStack {
                Button(action: restartCards) {
                    Text("Restart")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(sageGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: randomizeCards) {
                    Text("Randomize")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(sageGreen)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle("Flashcards")
        .sheet(isPresented: $showingList) {
            FlashcardListView(flashcardStore: flashcardStore, showingList: $showingList)
        }
    }
    
    func restartCards() {
        withAnimation {
            currentIndex = 0
        }
    }
    
    func randomizeCards() {
        flashcardStore.shuffleFlashcards()
        withAnimation {
            currentIndex = 0
        }
    }
}

struct FlashcardListView: View {
    @ObservedObject var flashcardStore: FlashcardStore
    @Binding var showingList: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(flashcardStore.flashcards) { flashcard in
                    VStack(alignment: .leading) {
                        Text(flashcard.title)
                            .font(.headline)
                        Text(flashcard.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .onDelete { indexSet in
                    flashcardStore.flashcards.remove(atOffsets: indexSet)
                    flashcardStore.saveFlashcards()
                }
            }
            .navigationTitle("Flashcard List")
            .navigationBarItems(
                leading: Button(action: { showingList = false }) {
                    Text("Back")
                },
                trailing: EditButton()
            )
        }
    }
}

struct FlashcardView: View {
    let flashcard: Flashcard
    @State private var flipped = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 5)
            
            VStack {
                if flipped {
                    Text(flashcard.description)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                } else {
                    Text(flashcard.title)
                        .font(.headline)
                }
            }
            .padding()
            .multilineTextAlignment(.center)
        }
        .frame(width: 300, height: 200)
        .rotation3DEffect(
            .degrees(flipped ? 180 : 0),
            axis: (x: 0.0, y: 1.0, z: 0.0)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                flipped.toggle()
            }
        }
    }
}

struct Content2View_Previews: PreviewProvider {
    static var previews: some View {
        Content2View(flashcardStore: FlashcardStore())
    }
}
