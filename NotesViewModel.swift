import SwiftUI
import AVFoundation

class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var isLoading: Bool = false

    private let saveKey = "savedNotes"
    private var audioPlayer: AVAudioPlayer?

    init() {
        loadNotes()
    }

    func add(note: Note) {
        notes.append(note)
        saveNotes()
    }

    func update(note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveNotes()
        }
    }

    func delete(note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes.remove(at: index)
            saveNotes()
        }
    }

    func saveNotes() {
        if let encodedData = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encodedData, forKey: saveKey)
        }
    }

    func loadNotes() {
        if let savedData = UserDefaults.standard.data(forKey: saveKey),
           let decodedNotes = try? JSONDecoder().decode([Note].self, from: savedData) {
            notes = decodedNotes
        }
    }

    func speakNote(note: Note) {
        isLoading = true

        // Prepare the request body
        let requestBody: [String: Any] = [
            "input": ["text": note.content],
            "voice": ["languageCode": "en-US", "ssmlGender": "NEUTRAL"],
            "audioConfig": ["audioEncoding": "MP3"]
        ]

        // Convert the request body to JSON data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("Failed to create JSON data")
            isLoading = false
            return
        }

        // Prepare the URL request
        guard let url = URL(string: "https://texttospeech.googleapis.com/v1/text:synthesize") else {
            print("Invalid URL")
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer YOUR_ACCESS_TOKEN", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        // Send the request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    print("Error: (error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data received")
                    return
                }

                // Parse the response
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let audioContent = json["audioContent"] as? String,
                       let audioData = Data(base64Encoded: audioContent) {
                        // Play the audio
                        self.playAudio(data: audioData)
                    }
                } catch {
                    print("Failed to parse response: (error.localizedDescription)")
                }
            }
        }.resume()
    }

    private func playAudio(data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.play()
        } catch {
            print("Failed to play audio: (error.localizedDescription)")
        }
    }
}
