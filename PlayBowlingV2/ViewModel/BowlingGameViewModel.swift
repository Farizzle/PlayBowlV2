//
//  BowlingGameViewModel.swift
//  PlayBowlingV2
//
//  Created by Metricell Developer on 30/03/2019.
//  Copyright © 2019 Metricell Developer. All rights reserved.
//

import Foundation

class BowlingGameViewModel: NSObject {
    
    var bowlingGameModel = BowlingGameModel()

    init(withBowlingGame: BowlingGame) {
        bowlingGameModel = withBowlingGame.bowlingGameModel
    }
    
    func getTotalScore() -> Int {
        guard let finalFrameScore = bowlingGameModel.frames.last?.last else {
            print("Game not finished")
            return 0
        }
        return finalFrameScore
    }
    
    func getCurrentScoreBoard() -> [[Int]] {
        return bowlingGameModel.frames
    }
    
}
