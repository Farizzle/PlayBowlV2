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
    
    // Setup viewModel with reference to a Bowling Game data source instance
    init(withBowlingGame: BowlingGame) {
        bowlingGameModel = withBowlingGame.bowlingGameModel
    }
    
    func getTotalScore() -> Int {
        if let finalFrameScore = bowlingGameModel.frames.last?.last{
            if (finalFrameScore == 0){
                print("Game not finished")
                return 0
            } else {
                return finalFrameScore
            }
        }
        return 0
    }
    
    func getCurrentScoreBoard() -> [[Int]] {
        return bowlingGameModel.frames
    }
    
}
