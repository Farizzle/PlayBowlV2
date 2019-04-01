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
    private var rollThree = Int()
    var bowlingGameModel = BowlingGameModel()
    var firstThrow = true
    var currentFrame: [Int]

    init() {
        currentFrame = bowlingGameModel.standardFrame
    }
    
    func finishGame(){
        bowlingGameModel.frameCount = bowlingGameModel.totalFrames + 1
        print("Game Finished")
    }
    
    func rollBall() {
        if (bowlingGameModel.frameCount < bowlingGameModel.totalFrames-1) {
            rollBallStandardFrame()
        } else {
            rollBallTenthFrame()
        }
    }
    
    func cleanUpRolls(){
        rollOne = 0
        rollTwo = 0
        rollThree = 0
    }
    
    func specialThrowConditionStandardFrame(){
        if (rollOne == 10){
            bowlingGameModel.specialThrow.onNext(bowlingGameModel.strikeCondition())
        } else if ((rollOne + rollTwo == 10) && rollOne != 10){
            bowlingGameModel.specialThrow.onNext(bowlingGameModel.spareCondition())
        }
    }
    
    func rollBallStandardFrame(){
        if (!firstThrow){
            rollTwo = Int.random(in: 0...(10-rollOne))
            specialThrowConditionStandardFrame()
            calculateScore()
            cleanUpRolls()
            bowlingGameModel.frameCount += 1
            cleanUpRolls()
            firstThrow = true
        } else {
            rollOne = Int.random(in: 0...10)
            specialThrowConditionStandardFrame()
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
    
    func rollBallTenthFrame(){
        if (bowlingGameModel.rollCount < bowlingGameModel.tenthFrameMaxRolls+1){
            switch (bowlingGameModel.rollCount){
            case 0:
                rollOne = Int.random(in: 0...10)
                print(rollOne)
                if (rollOne == 10){
                    bowlingGameModel.specialThrow.onNext(bowlingGameModel.strikeCondition())
                }
                calculateScore()
                bowlingGameModel.rollCount += 1
                break
            case 1:
                if (rollOne < 10){
                    rollTwo = Int.random(in: 0...(10-rollOne))
                } else {
                    rollTwo = Int.random(in: 0...10)
                }
                if (rollOne + rollTwo == 10 && rollOne != 10){
                    bowlingGameModel.specialThrow.onNext(bowlingGameModel.spareCondition())
                } else if (rollTwo == 10 && rollOne == 10){
                    bowlingGameModel.specialThrow.onNext(bowlingGameModel.strikeCondition())
                }
                calculateScore()
                bowlingGameModel.rollCount += 1
                if (rollOne != 10){
                    if (rollTwo + rollOne < 10){
                        bowlingGameModel.rollCount += 1
                    }
                }
                break
            case 2:
                if (rollTwo < 10){
                    rollThree = Int.random(in: 0...(10-rollTwo))
                } else {
                    rollThree = Int.random(in: 0...10)
                }
                if (rollTwo + rollThree == 10 && rollTwo != 10){
                    bowlingGameModel.specialThrow.onNext(bowlingGameModel.spareCondition())
                } else if (rollThree == 10 && rollTwo == 10){
                    bowlingGameModel.specialThrow.onNext(bowlingGameModel.strikeCondition())
                }
                calculateScore()
                bowlingGameModel.rollCount += 1
                break
            default:
                break
            }
        } else {
            finishGame()
        }

    }
    
    func calculateScore() {
        if (bowlingGameModel.frameCount < 9){
            scoreForStandardFrames()
        } else {
            scoreForTenthFrame()
        }
    }
    
    func scoreForStandardFrames(){
        if let previousFrame = bowlingGameModel.frames[safe: bowlingGameModel.frameCount-1]{
            currentFrame = [rollOne, rollTwo, rollOne+rollTwo + previousFrame[2]]
            if (wasStrike()){
                if (wasContiniousStrike()){
                    if (currentFrame[1] == 0){
                        if let twoPreviousFrames = bowlingGameModel.frames[safe: bowlingGameModel.frameCount-2]{
                            let appendedTwoPreviousFrames = [twoPreviousFrames[0], twoPreviousFrames[1], twoPreviousFrames[2] + currentFrame[0]]
                            bowlingGameModel.frames[bowlingGameModel.frameCount-2] = appendedTwoPreviousFrames
                            let appendedPreviousFrame = [previousFrame[0], previousFrame[1], appendedTwoPreviousFrames[2] + previousFrame[0] + currentFrame[0]]
                            bowlingGameModel.frames[bowlingGameModel.frameCount-1] = appendedPreviousFrame
                            let appendedCurrentFrame = [currentFrame[0], currentFrame[1], appendedPreviousFrame[2] + currentFrame[0]]
                            bowlingGameModel.frames[bowlingGameModel.frameCount] = appendedCurrentFrame
                            bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
                        }
                    } else {
                        let appendedPreviousFrame = [previousFrame[0], previousFrame[1], previousFrame[2] + currentFrame[1]]
                        bowlingGameModel.frames[bowlingGameModel.frameCount-1] = appendedPreviousFrame
                        let appendedCurrentFrame = [currentFrame[0], currentFrame[1], appendedPreviousFrame[2] + currentFrame[0] + currentFrame[1]]
                        bowlingGameModel.frames[bowlingGameModel.frameCount] = appendedCurrentFrame
                        bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
                    }
                } else {
                    if (firstThrow){
                        let appendedPreviousFrame = [previousFrame[0], previousFrame[1], previousFrame[2] + currentFrame[0]]
                        bowlingGameModel.frames[bowlingGameModel.frameCount-1] = appendedPreviousFrame
                        bowlingGameModel.frames[bowlingGameModel.frameCount] = currentFrame
                        bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
                    } else {
                        let appendedPreviousFrame = [previousFrame[0], previousFrame[1], previousFrame[2] + currentFrame[1]]
                        bowlingGameModel.frames[bowlingGameModel.frameCount-1] = appendedPreviousFrame
                        let appendedCurrentFrame = [currentFrame[0], currentFrame[1], appendedPreviousFrame[2] + currentFrame[0] + currentFrame[1]]
                        bowlingGameModel.frames[bowlingGameModel.frameCount] = appendedCurrentFrame
                        bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
                    }
                    
                }
            } else if (wasSpare() && firstThrow){
                let appendedPreviousFrame = [previousFrame[0], previousFrame[1], previousFrame[2] + currentFrame[0]]
                bowlingGameModel.frames[bowlingGameModel.frameCount-1] = appendedPreviousFrame
                let appendedCurrentFrame = [currentFrame[0], currentFrame[1], appendedPreviousFrame[2] + currentFrame[0] + currentFrame[1]]
                bowlingGameModel.frames[bowlingGameModel.frameCount] = appendedCurrentFrame
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
    
    func scoreForTenthFrame(){
        if let previousFrame = bowlingGameModel.frames[safe: bowlingGameModel.frameCount-1]{
            if (bowlingGameModel.rollCount == 2){
                currentFrame = [rollOne, rollTwo, rollThree, rollOne+rollTwo+rollThree + previousFrame[2]]
                bowlingGameModel.frames[bowlingGameModel.frameCount] = currentFrame
                bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
                return
            }
            currentFrame = [rollOne, rollTwo, rollThree, rollOne+rollTwo+rollThree + previousFrame[2]]
            if (wasStrike()){
                if (wasContiniousStrike()){
                    if (currentFrame[1] == 0){
                        if let twoPreviousFrames = bowlingGameModel.frames[safe: bowlingGameModel.frameCount-2]{
                            let appendedTwoPreviousFrames = [twoPreviousFrames[0], twoPreviousFrames[1], twoPreviousFrames[2] + currentFrame[0]]
                            bowlingGameModel.frames[bowlingGameModel.frameCount-2] = appendedTwoPreviousFrames
                            let appendedPreviousFrame = [previousFrame[0], previousFrame[1], appendedTwoPreviousFrames[2] + previousFrame[0] + currentFrame[0]]
                            bowlingGameModel.frames[bowlingGameModel.frameCount-1] = appendedPreviousFrame
                            let appendedCurrentFrame = [currentFrame[0], currentFrame[1], currentFrame[2], appendedPreviousFrame[2] + currentFrame[0]]
                            bowlingGameModel.frames[bowlingGameModel.frameCount] = appendedCurrentFrame
                            bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
                        }
                    } else {
                        let appendedPreviousFrame = [previousFrame[0], previousFrame[1], previousFrame[2] + currentFrame[1]]
                        bowlingGameModel.frames[bowlingGameModel.frameCount-1] = appendedPreviousFrame
                        let appendedCurrentFrame = [currentFrame[0], currentFrame[1], currentFrame[2], appendedPreviousFrame[2] + currentFrame[0] + currentFrame[1]]
                        bowlingGameModel.frames[bowlingGameModel.frameCount] = appendedCurrentFrame
                        bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
                    }
                } else {
                    if (bowlingGameModel.rollCount == 0){
                        let appendedPreviousFrame = [previousFrame[0], previousFrame[1], previousFrame[2] + currentFrame[0]]
                        bowlingGameModel.frames[bowlingGameModel.frameCount-1] = appendedPreviousFrame
                        bowlingGameModel.frames[bowlingGameModel.frameCount] = currentFrame
                        bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
                    } else {
                        let appendedPreviousFrame = [previousFrame[0], previousFrame[1], previousFrame[2] + currentFrame[1]]
                        bowlingGameModel.frames[bowlingGameModel.frameCount-1] = appendedPreviousFrame
                        let appendedCurrentFrame = [currentFrame[0], currentFrame[1], currentFrame[2], appendedPreviousFrame[2] + currentFrame[0] + currentFrame[1]]
                        bowlingGameModel.frames[bowlingGameModel.frameCount] = appendedCurrentFrame
                        bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
                    }
                    
                }
            } else if (wasSpare() && bowlingGameModel.rollCount == 0){
                let appendedPreviousFrame = [previousFrame[0], previousFrame[1], previousFrame[2] + currentFrame[0]]
                bowlingGameModel.frames[bowlingGameModel.frameCount-1] = appendedPreviousFrame
                let appendedCurrentFrame = [currentFrame[0], currentFrame[1], currentFrame[2], appendedPreviousFrame[2] + currentFrame[0] + currentFrame[1]]
                bowlingGameModel.frames[bowlingGameModel.frameCount] = appendedCurrentFrame
                bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
            } else {
                bowlingGameModel.frames[bowlingGameModel.frameCount] = currentFrame
                bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
            }
        } else {
            currentFrame = [rollOne, rollTwo, rollThree, rollOne+rollTwo+rollThree]
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
    
    func wasContiniousStrike() -> Bool{
        guard let previousFrame = bowlingGameModel.frames[safe: bowlingGameModel.frameCount-1] else {return false}
        guard let twoPreviousFrames = bowlingGameModel.frames[safe: bowlingGameModel.frameCount-2] else {return false}
        if (previousFrame[0] == 10 && twoPreviousFrames[0] == 10){
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
