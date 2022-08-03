//
//  Game.swift
//  bugzero-kata
//
//  Created by Frédéric Ruaudel on 20/04/2018.
//

import Foundation

enum GameErrors: Error {
    case notEnoughPlayers
}
enum TypeOfQuestions: String, CaseIterable{
    case pop
    case science
    case sports
    case rock
    case art

}

struct QuestionStack {
    private (set) var  questions:[String] = []
    var type: TypeOfQuestions
    private(set) var currentIndex:Int = 0
    init(type:TypeOfQuestions, numberQuestions: Int) {
        self.type = type
        self.questions = (0..<numberQuestions).map({ num in
            return "\(type.rawValue.capitalized) question \(num)"
        })
    }
    
    mutating func next() -> String {
        let question = self.questions[currentIndex]
        currentIndex += 1
        if (currentIndex == question.count) { currentIndex = 0}
        return question
    }
    
    
}

class Game {
    var players = [String]()
    var places = [Int]()
    var purses = [Int]()
    var inPenaltyBox = [Bool]()
    var board: [TypeOfQuestions?] = []
    var questions: [TypeOfQuestions: QuestionStack] = [:]

    var currentPlayer: Int = 0
    var isGettingOutOfPenaltyBox: Bool = false
    
    init(numberOfQuestionsPerType: Int = 50, lengthBoard: Int = 12) {
        let stepByTypeOfQuestion = TypeOfQuestions.allCases.count
        self.board = Array(repeating: nil, count: lengthBoard)
        TypeOfQuestions.allCases.forEach { question in
            let nextValue: Int? = self.board.firstIndex(of: nil)
            self.questions[question] = QuestionStack(type: question, numberQuestions: numberOfQuestionsPerType)
            if let nextValue = nextValue {
                for i in stride(from: nextValue, through: lengthBoard - 1, by: stepByTypeOfQuestion){
                    self.board[i] = question
                }
            }
            
        }
        print(board)
    }
    
    func createRockQuestions(index: Int) -> String {
        return "Rock question \(index)"
    }
    
    func isPlayable() -> Bool {
        return (howManyPlayers() >= 2)
    }
    
    func add(_ playerName: String) -> Bool {
        players.append(playerName)
        places.append(0)
        purses.append(0)
        inPenaltyBox.append(false)
        
        print("\(playerName) was added")
        print("They are player number \(players.count)")
        
        return true
    }
    
    func howManyPlayers() -> Int {
        return players.count
    }
    
    func roll(_ roll: Int) throws{
        guard self.isPlayable() else {
            throw GameErrors.notEnoughPlayers
        }
        print("\(players[currentPlayer]) is the current player")
        print("They have rolled a \(roll)")
        
        if inPenaltyBox[currentPlayer] {
            if roll % 2 != 0 {
                isGettingOutOfPenaltyBox = true
                print("\(players[currentPlayer]) is getting out of the penalty box")
                movePlayerAndAskQuestion(roll)
            } else {
                print("\(players[currentPlayer]) is not getting out of the penalty box")
                isGettingOutOfPenaltyBox = false
            }
        } else {
            movePlayerAndAskQuestion(roll)
        }
    }
    
    private func movePlayerAndAskQuestion(_ roll: Int) {
        places[currentPlayer] = places[currentPlayer] + roll
        if places[currentPlayer] > 11 {
            places[currentPlayer] -= 12
        }
        
        print("\(players[currentPlayer])'s new location is \(places[currentPlayer])")
        print("The category is \(currentCategory())")
        
        askQuestion()
    }
    
    private func askQuestion() {
        guard let question = self.questions[currentCategory()]?.next() else{
            return
        }
        print(question)
    }
    
    private func currentCategory() -> TypeOfQuestions {
        if places[currentPlayer] == 0 { return .pop };
        if places[currentPlayer] == 4 { return .pop };
        if places[currentPlayer] == 8 { return .pop };
        if places[currentPlayer] == 1 { return .science };
        if places[currentPlayer] == 5 { return .science };
        if places[currentPlayer] == 9 { return .science };
        if places[currentPlayer] == 2 { return .sports };
        if places[currentPlayer] == 6 { return .sports };
        if places[currentPlayer] == 10 { return .sports };
        return .rock;
    }
    private func moveToNextPlayer() {
        currentPlayer += 1
        if (currentPlayer == players.count) { currentPlayer = 0 }
    }
    func wasCorrectlyAnswered() -> Bool {
        if inPenaltyBox[currentPlayer] {
            if isGettingOutOfPenaltyBox {
                print("Answer was correct!!!!")
                
                purses[currentPlayer] += 1
                print("\(players[currentPlayer]) now has \(purses[currentPlayer]) Gold Coins.")
                moveToNextPlayer()
                let winner = didPlayerWin()
                
                return winner
            } else {
                moveToNextPlayer()
                return true
            }
        } else {
            // Not in penalty box
            print("Answer was correct!!!!")
            // Add points
            purses[currentPlayer] += 1
            print("\(players[currentPlayer]) now has \(purses[currentPlayer]) Gold Coins.")
            // Checks if player win
            let winner = didPlayerWin()
            // Move to next player or return to first player
            moveToNextPlayer()
            
            return winner
        }
    }
    
    func wrongAnswer() -> Bool {
        print("Question was incorrectly answered")
        print("\(players[currentPlayer]) was sent to the penalty box")
        inPenaltyBox[currentPlayer] = true
        
        currentPlayer += 1
        if (currentPlayer == players.count) { currentPlayer = 0 }
        return true
    }
    
    private func didPlayerWin() -> Bool {
        return !(purses[currentPlayer] == 6)
    }
}
