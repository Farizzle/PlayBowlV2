//
//  BowlingGame.swift
//  PlayBowlingV2
//
//  Created by Metricell Developer on 30/03/2019.
//  Copyright © 2019 Metricell Developer. All rights reserved.
//

import Foundation
import RxSwift

class BowlingGame{
    
    private var rollOne = Int()
    private var rollTwo = Int()
    var bowlingGameModel = BowlingGameModel()
    var firstThrow = true
    var currentFrame: [Int]

    init() {
        currentFrame = bowlingGameModel.standardFrame
    }
    
    func rollBall() {
        if (bowlingGameModel.frameCount < bowlingGameModel.totalFrames) {
            if (!firstThrow){
//                rollTwo = Int.random(in: 0...(10-rollOne))
                rollTwo = 10-rollOne
                print(rollTwo)
                calculateScore()
                cleanUpRolls()
                bowlingGameModel.frameCount += 1
                cleanUpRolls()
                firstThrow = true
            } else {
                rollOne = Int.random(in: 0...9)
//                rollOne = 10
                print(rollOne)
                calculateScore()
                if (rollOne == 10){
                    firstThrow = true
                    bowlingGameModel.frameCount += 1
                    cleanUpRolls()
                } else {
                    firstThrow = false
                }
            }
        }
    }
    
    func cleanUpRolls(){
        rollOne = 0
        rollTwo = 0
    }
    
    func calculateScore() {
        
        if let previousFrame = bowlingGameModel.frames[safe: bowlingGameModel.frameCount-1]{
            currentFrame = [rollOne, rollTwo, rollOne+rollTwo + previousFrame[2]]
            if (wasStrike()){
                let appendedPreviousFrame = [previousFrame[0], previousFrame[1], previousFrame[2] + currentFrame[0] + currentFrame[1]]
                bowlingGameModel.frames[bowlingGameModel.frameCount-1] = appendedPreviousFrame
                bowlingGameModel.frames[bowlingGameModel.frameCount] = currentFrame
                bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
            } else if (wasSpare() && firstThrow){
                let appendedPreviousFrame = [previousFrame[0], previousFrame[1], previousFrame[2] + currentFrame[0]]
                bowlingGameModel.frames[bowlingGameModel.frameCount-1] = appendedPreviousFrame
                bowlingGameModel.frames[bowlingGameModel.frameCount] = currentFrame
                bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
            } else {
                bowlingGameModel.frames[bowlingGameModel.frameCount] = currentFrame
                bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
            }
        } else {
            currentFrame = [rollOne, rollTwo, rollOne+rollTwo]
            bowlingGameModel.frames[bowlingGameModel.frameCount] = currentFrame
            bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
        }
    }
    
    func wasStrike() -> Bool {
        guard let previousFrame = bowlingGameModel.frames[safe: bowlingGameModel.frameCount-1] else {return false}
        if (previousFrame[0] == 10) {
            return true
        } else {
            return false
        }
    }
    
    func wasSpare() -> Bool {
        guard let previousFrame = bowlingGameModel.frames[safe: bowlingGameModel.frameCount-1] else {return false}
        if (previousFrame[0] + previousFrame[1] == 10){
            return true
        } else {
            return false
        }
    }
    
}
