import Foundation

struct Question {
    let question: String
    let options: [String]
    let answer: Int
}

struct Subject {
    let name: String
    let questions: [Question]
}

let mathQuestions = [
    Question(question: "What is 2 + 2?", options: ["3", "4", "5", "6"], answer: 1),
    Question(question: "What is 5 x 3?", options: ["15", "20", "25", "30"], answer: 0)
]

let readingQuestions = [
    Question(question: "What is the main idea of a story?", options: ["The plot", "The setting", "The theme", "The characters"], answer: 2),
    Question(question: "What do you call a person who writes a book?", options: ["Author", "Editor", "Publisher", "Reader"], answer: 0)
]

let scienceQuestions = [
    Question(question: "What planet is known as the Red Planet?", options: ["Earth", "Mars", "Jupiter", "Venus"], answer: 1),
    Question(question: "What gas do plants breathe in?", options: ["Oxygen", "Hydrogen", "Carbon Dioxide", "Nitrogen"], answer: 2)
]

let historyQuestions = [
    Question(question: "Who was the first President of the United States?", options: ["Abraham Lincoln", "Thomas Jefferson", "George Washington", "John Adams"], answer: 2),
    Question(question: "In which year did World War II end?", options: ["1942", "1945", "1948", "1950"], answer: 1)
]

let subjects = [
    Subject(name: "Math", questions: mathQuestions),
    Subject(name: "Reading", questions: readingQuestions),
    Subject(name: "Science", questions: scienceQuestions),
    Subject(name: "History", questions: historyQuestions)
]

func getRandomQuestions(from subjects: [Subject]) -> [Question] {
    var allQuestions = subjects.flatMap { $0.questions }
    allQuestions.shuffle()
    return allQuestions
}
