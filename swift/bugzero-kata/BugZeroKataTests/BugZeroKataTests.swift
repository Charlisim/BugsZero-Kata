//
//  BugZeroKataTests.swift
//  BugZeroKataTests
//
//  Created by Carlos Simon Villas on 2/08/22.
//  Copyright © 2022 Frédéric Ruaudel. All rights reserved.
//

import XCTest

class BugZeroKataTests: XCTestCase {
    func testGameDontStartIfThereAreNoPlayers() throws {
        let game = Game()
       
        XCTAssertThrowsError(try game.roll(Int(arc4random_uniform(6)))) { error in
            XCTAssertEqual(error as? GameErrors, GameErrors.notEnoughPlayers)
        }
    }
    
    
    private func createWith3Players() -> Game {
        let game = Game()
        _ = game.add("Alice")
        _ = game.add("John")
        _ = game.add("Ron")
        return game
    }
    
    func testPlayerMovesBetweenPlayers() throws {
        let game = createWith3Players()
        try? game.roll(4)
        var _ = game.wasCorrectlyAnswered()
        XCTAssertEqual(game.currentPlayer, 1)
    }
    func testMoveToFirstPlayerAfterLastOne() throws {
        let game = createWith3Players()
        game.currentPlayer = 2
        try? game.roll(4)
        var _ = game.wasCorrectlyAnswered()
        XCTAssertEqual(game.currentPlayer, 0)
    }
    
    func testCoinsAreForTheRightPlayer() throws {
        let game = createWith3Players()
        try? game.roll(4)
        var _ = game.wasCorrectlyAnswered()
        XCTAssertEqual(game.purses[0], 1)
    }
    
    func testCoinsAreForTheRightPlayerAfterReturningFromPrision() throws {
        let game = createWith3Players()
        try? game.roll(4)
        _ = game.wrongAnswer()
        game.currentPlayer = 0
        try? game.roll(3)
        var _ = game.wasCorrectlyAnswered()
        XCTAssertEqual(game.purses[0], 1)
    }
    
    func testDoesntGoOutFromPrisionIfRollEven() throws {
        let game = createWith3Players()
        try? game.roll(4)
        game.wrongAnswer()
        game.currentPlayer = 0
        try? game.roll(2)
        var _ = game.wasCorrectlyAnswered()
        XCTAssertEqual(game.purses[0], 0)
    }
    
    func testPositionGoesCircularReachingEndOfBoard() {
        let game = createWith3Players()
        try? game.roll(4)
        try? game.roll(10)
        XCTAssertEqual(game.places[game.currentPlayer], 2)
    }
    
    func testLoopsPlayerWhenReachingLastPlayer() {
        let game = createWith3Players()
        try? game.roll(4)
        _ = game.wasCorrectlyAnswered()
        XCTAssertEqual(game.currentPlayer, 1)
        try? game.roll(4)
        _ = game.wasCorrectlyAnswered()
        XCTAssertEqual(game.currentPlayer, 2)
        try? game.roll(4)
        _ = game.wasCorrectlyAnswered()
        XCTAssertEqual(game.currentPlayer, 0)
        try? game.roll(4)
        _ = game.wasCorrectlyAnswered()
        XCTAssertEqual(game.currentPlayer, 1)
    }
    func testQuestionCreatesArrayOfTheInitializedLength(){
        let stack = QuestionStack(type: .rock, numberQuestions: 50)
        XCTAssertEqual(stack.questions.count, 50)
    }
    func testQuestionStackMoveToNextIndex(){
        var stack = QuestionStack(type: .rock, numberQuestions: 50)
        _ = stack.next()
        XCTAssertEqual(stack.currentIndex, 1)
    }
    
    func testBoardPositionsAndDistributedEvenly() {
        let numberOfIterations = 4

        let lengthBoard = TypeOfQuestions.allCases.count * numberOfIterations
        let game = Game(numberOfQuestionsPerType: 50, lengthBoard: lengthBoard)
        
        TypeOfQuestions.allCases.forEach { question in
            XCTAssertEqual(game.board.filter({$0 == question}).count, numberOfIterations)
        }
        
    }
    
    
    

    

}
