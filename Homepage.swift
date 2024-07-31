//
//  Homepage.swift
//  study-sage
//
//  Created by csuftitan on 7/30/24.
//
import SwiftUI

struct HomePage: View {
    @StateObject private var flashcardStore = FlashcardStore()
    
    let sageGreen = Color(red: 0.5, green: 0.7, blue: 0.6)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("StudySageLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(.top, 50)
                
                Text("Study Sage")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: Content2View(flashcardStore: flashcardStore)) {
                    HomePageButton(title: "Add Flashcards", color: sageGreen)
                }
                
                NavigationLink(destination: FlashcardsDisplayView(flashcardStore: flashcardStore)) {
                    HomePageButton(title: "View Flashcards", color: sageGreen)
                }
                
                NavigationLink(destination: SubjectSelectionView()) {
                    HomePageButton(title: "Quiz", color: sageGreen)
                }
                
                NavigationLink(destination: WriteNotes()) {
                    HomePageButton(title: "Notes", color: sageGreen)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

struct HomePageButton: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .cornerRadius(10)
    }
}

struct TakeQuizView: View {
    var body: some View {
        Text("Take Quiz View")
            .navigationTitle("Take Quiz")
    }
}

struct NotesView: View {
    var body: some View {
        Text("Notes View")
            .navigationTitle("Notes")
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
    }
}
