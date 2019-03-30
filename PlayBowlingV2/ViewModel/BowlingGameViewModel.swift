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
    
    func calculateFrameScore() -> Int {
        guard let frameRollOne = bowlingGameModel.rolls[safe: bowlingGameModel.rollCount-1] else { return 0 }
        guard let frameRollTwo = bowlingGameModel.rolls.last else { return 0 }
        return frameRollOne! + frameRollTwo!
    }
    
    
    
}
