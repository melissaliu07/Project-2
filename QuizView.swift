import SwiftUI

struct QuizView: View {
    let questions: [Question]
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswerIndex: Int? = nil
    @State private var score = 0
    @State private var showingResult = false

    var body: some View {
        VStack {
            Text(questions[currentQuestionIndex].question)
                .font(.title)
                .padding()
            
            let options = questions[currentQuestionIndex].options
            
            VStack {
                ForEach(0..<options.count / 2) { rowIndex in
                    HStack {
                        ForEach(0..<2) { columnIndex in
                            let index = rowIndex * 2 + columnIndex
                            if index < options.count {
                                Button(action: {
                                    selectedAnswerIndex = index
                                }) {
                                    Text(options[index])
                                        .padding()
                                        .frame(width: 175, height: 175)
                                        .background(selectedAnswerIndex == index ? Color.yellow : Color(red: 0.5, green: 0.7, blue: 0.6))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding(.bottom, 5)
                            }
                        }
                    }
                }
            }

            Button(action: {
                checkAnswer()
            }) {
                Text("Submit")
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)

            Spacer()

            Text("Score: \(score)")
                .padding(.top, 20)
        }
        .alert(isPresented: $showingResult) {
            Alert(
                title: Text("Quiz Finished"),
                message: Text("Your score is \(score)"),
                dismissButton: .default(Text("Restart"), action: {
                    restartQuiz()
                })
            )
        }
        .padding()
    }

    func checkAnswer() {
        if let selectedAnswerIndex = selectedAnswerIndex {
            if selectedAnswerIndex == questions[currentQuestionIndex].answer {
                score += 1
            }
            nextQuestion()
        }
    }

    func nextQuestion() {
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
            selectedAnswerIndex = nil
        } else {
            showingResult = true
        }
    }

    func restartQuiz() {
        currentQuestionIndex = 0
        selectedAnswerIndex = nil
        score = 0
        showingResult = false
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView(questions: subjects[0].questions)
    }
}
