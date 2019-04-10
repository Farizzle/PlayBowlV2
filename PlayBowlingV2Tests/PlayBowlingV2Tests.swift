//
//  PlayBowlingV2Tests.swift
//  PlayBowlingV2Tests
//
//  Created by Metricell Developer on 09/04/2019.
//  Copyright © 2019 Metricell Developer. All rights reserved.
//

import XCTest
@testable import PlayBowlingV2

class PlayBowlingV2Tests: XCTestCase {

    let bowlingGame = BowlingGame.init()
    var bowlingGameViewModel: BowlingGameViewModel?
    
    override func setUp() {
        bowlingGameViewModel = BowlingGameViewModel.init(withBowlingGame: bowlingGame)
    }

    func testAllStrikes() {
        setUp()
        // Complete all 10 frames by throwing all strikes
        for _ in 0...11{
           bowlingGame.testRollBall(firstRoll: 10, secondRoll: 10, thirdRoll: 10)
        }
        if let finalScore = bowlingGameViewModel?.getTotalScore(){
            if (finalScore == 300){
                XCTAssert(true)
            } else {
                XCTAssert(false)
            }
        }
    }
    
    func testAllSpares() {
        setUp()
        // Roll 21 times throwing all spares (5s)
        for _ in 0...22{
            bowlingGame.testRollBall(firstRoll: 5, secondRoll: 5, thirdRoll: 5)
        }
        if let finalScore = bowlingGameViewModel?.getTotalScore(){
            if (finalScore == 150){
                XCTAssert(true)
            } else {
                XCTAssert(false)
            }
        }
    }

}
