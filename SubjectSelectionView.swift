//
//  SubjectSelectionView.swift
//  study-sage
//
//  Created by csuftitan on 7/30/24.
//

import SwiftUI

struct SubjectSelectionView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Select a Subject")
                    .font(.largeTitle)
                    .padding()

                ForEach(subjects, id: \.name) { subject in
                    NavigationLink(destination: QuizView(questions: subject.questions)) {
                        Text(subject.name)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.5, green: 0.7, blue: 0.6))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 10)
                }

                NavigationLink(destination: QuizView(questions: getRandomQuestions(from: subjects))) {
                    Text("Random")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom, 10)

                Spacer()
            }
            .padding()
        }
    }
}

struct SubjectSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SubjectSelectionView()
    }
}
