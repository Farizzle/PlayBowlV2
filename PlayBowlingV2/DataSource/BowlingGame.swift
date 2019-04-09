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
        bowlingGameModel.frameCount = bowlingGameModel.frameCount + 1
        print("Game Finished")
    }
    
    func rollBall() {
        // From 1-9 roll for a standard frame (Max 2 throws)
        if (bowlingGameModel.frameCount < bowlingGameModel.totalFrames-1) {
            rollBallStandardFrame()
        } else {
            // Frame 10 roll for a frame where potentially (Max 3 throws)
            rollBallTenthFrame()
        }
    }
    
    func cleanUpRolls(){
        // Reset rolls after they've been stored into a frame object
        rollOne = 0
        rollTwo = 0
        rollThree = 0
    }
    
    func specialThrowConditionStandardFrame(){
        // Check if roll one was a strike
        if (rollOne == 10){
            bowlingGameModel.specialThrow.onNext(bowlingGameModel.strikeCondition())
            // Check if roll two resulted in a spare
        } else if ((rollOne + rollTwo == 10) && rollOne != 10){
            bowlingGameModel.specialThrow.onNext(bowlingGameModel.spareCondition())
        }
    }
    
    func rollBallStandardFrame(){
        if (!firstThrow){
            // Roll second ball and complete frame
            rollTwo = Int.random(in: 0...(10-rollOne))
            specialThrowConditionStandardFrame()
            calculateScore()
            cleanUpRolls()
            bowlingGameModel.frameCount += 1
            bowlingGameModel.frameComplete.onNext(true)
            cleanUpRolls()
            firstThrow = true
        } else {
            // Roll first ball
            rollOne = Int.random(in: 0...10)
            specialThrowConditionStandardFrame()
            calculateScore()
            if (rollOne == 10){
                // Check if roll was a strike, if so complete frame
                firstThrow = true
                bowlingGameModel.frameCount += 1
                bowlingGameModel.frameComplete.onNext(true)
                cleanUpRolls()
            } else {
                firstThrow = false
            }
        }
    }
    
    
    func rollBallTenthFrame(){
        if (bowlingGameModel.rollCount <= bowlingGameModel.tenthFrameMaxRolls){
            switch (bowlingGameModel.rollCount){
            case 0:
                // Roll first ball of tenth frame and increase rollcount
                rollOne = Int.random(in: 0...10)
                print(rollOne)
                if (rollOne == 10){
                    bowlingGameModel.specialThrow.onNext(bowlingGameModel.strikeCondition())
                }
                firstThrow = true
                calculateScore()
                firstThrow = false
                bowlingGameModel.rollCount += 1
                break
            case 1:
                // Roll second ball of tenth frame and increase rollcount
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
                        // If roll one and two didn't produce a spare, or were not strikes, complete this frame - game is now finished
                        bowlingGameModel.frameComplete.onNext(false)
                        bowlingGameModel.rollCount += 1
                    }
                }
                break
            case 2:
                // If criteria met from roll one and two, roll the third and final ball - game is now finished.
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
                // Let VC know the game is finished
                bowlingGameModel.frameComplete.onNext(false)
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
            // From frame 1-9 consider the scoring to only account for a frame (Max 2 throws)
            scoreForStandardFrames()
        } else {
            // For frame 10 consider the scoring for a frame which potentially (Max 3 throws)
            scoreForTenthFrame()
        }
    }
    
    func scoreForStandardFrames(){
        // Obtain a reference from the previous frame incase it needs updating
        if let previousFrame = bowlingGameModel.frames[safe: bowlingGameModel.frameCount-1]{
            currentFrame = [rollOne, rollTwo, rollOne+rollTwo + previousFrame[2]]
            if (wasStrike()){
                // Check if previous frame was a strike
                if (wasContiniousStrike()){
                    // Check if previous frame, and the one prior were both strikes
                    if (currentFrame[1] == 0){
                        // Update two frames behind with the second throw (if previous was also a strike)
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
                        // If two frames behind was a strike update with first throw of current frame
                        let appendedPreviousFrame = [previousFrame[0], previousFrame[1], previousFrame[2] + currentFrame[0]]
                        bowlingGameModel.frames[bowlingGameModel.frameCount-1] = appendedPreviousFrame
                        bowlingGameModel.frames[bowlingGameModel.frameCount] = currentFrame
                        bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
                    } else {
                        // If two frames behind was a strike update with second throw of current frame
                        let appendedPreviousFrame = [previousFrame[0], previousFrame[1], previousFrame[2] + currentFrame[1]]
                        bowlingGameModel.frames[bowlingGameModel.frameCount-1] = appendedPreviousFrame
                        let appendedCurrentFrame = [currentFrame[0], currentFrame[1], appendedPreviousFrame[2] + currentFrame[0] + currentFrame[1]]
                        bowlingGameModel.frames[bowlingGameModel.frameCount] = appendedCurrentFrame
                        bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
                    }
                    
                }
            } else if (wasSpare() && firstThrow){
                // Check if previous frame was a spare, so update it with the first throw of current frame
                let appendedPreviousFrame = [previousFrame[0], previousFrame[1], previousFrame[2] + currentFrame[0]]
                bowlingGameModel.frames[bowlingGameModel.frameCount-1] = appendedPreviousFrame
                let appendedCurrentFrame = [currentFrame[0], currentFrame[1], appendedPreviousFrame[2] + currentFrame[0] + currentFrame[1]]
                bowlingGameModel.frames[bowlingGameModel.frameCount] = appendedCurrentFrame
                bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
            } else {
                // Update current frame with the secondary throw
                bowlingGameModel.frames[bowlingGameModel.frameCount] = currentFrame
                bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
            }
        } else {
            // Standard previous frame, so just update current frame with roll one and two
            currentFrame = [rollOne, rollTwo, rollOne+rollTwo]
            bowlingGameModel.frames[bowlingGameModel.frameCount] = currentFrame
            bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
        }
    }
    
    func scoreForTenthFrame(){
        // Obtain a reference from the previous frame incase it needs updating
        if let previousFrame = bowlingGameModel.frames[safe: bowlingGameModel.frameCount-1]{
            if (bowlingGameModel.rollCount == 2){
                // If we're on the third throw of the tenth frame, just update the current frame with the total
                currentFrame = [rollOne, rollTwo, rollThree, rollOne+rollTwo+rollThree + previousFrame[2]]
                bowlingGameModel.frames[bowlingGameModel.frameCount] = currentFrame
                bowlingGameModel.framesSubject.onNext(bowlingGameModel.frames)
                return
            }
            currentFrame = [rollOne, rollTwo, rollThree, rollOne+rollTwo+rollThree + previousFrame[2]]
            if (wasStrike()){
                // Check if previous frame was a strike
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
                    if (firstThrow){
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
            } else if (wasSpare() && firstThrow){
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
    
    
    // TEST METHODS
    // Testable version of rollBall
    func testRollBall(firstRoll: Int, secondRoll: Int?, thirdRoll: Int?) {
        // From 1-9 roll for a standard frame (Max 2 throws)
        if (bowlingGameModel.frameCount < bowlingGameModel.totalFrames-1) {
            testRollBallStandardFrame(firstRoll: firstRoll, secondRoll: secondRoll)
        } else {
            // Frame 10 roll for a frame where potentially (Max 3 throws)
            testRollBallTenthFrame(firstRoll: firstRoll, secondRoll: secondRoll, thirdRoll: thirdRoll)
        }
    }
    
    // Testable version of standardFrame
    func testRollBallStandardFrame(firstRoll: Int, secondRoll: Int?){
        if let secondRollAvailable = secondRoll {
            if (firstRoll > 10 || secondRollAvailable > 10){
                return
            }
            if ((firstRoll != 10) && (firstRoll + secondRollAvailable > 10)){
                return
            }
            if (!firstThrow){
                // Roll second ball and complete frame
                rollTwo = secondRollAvailable
                specialThrowConditionStandardFrame()
                calculateScore()
                cleanUpRolls()
                bowlingGameModel.frameCount += 1
                bowlingGameModel.frameComplete.onNext(true)
                cleanUpRolls()
                firstThrow = true
            } else {
                // Roll first ball
                rollOne = firstRoll
                specialThrowConditionStandardFrame()
                calculateScore()
                if (rollOne == 10){
                    // Check if roll was a strike, if so complete frame
                    firstThrow = true
                    bowlingGameModel.frameCount += 1
                    bowlingGameModel.frameComplete.onNext(true)
                    cleanUpRolls()
                } else {
                    firstThrow = false
                }
            }
        }
    }

    // Testable version of tenth frame
    func testRollBallTenthFrame(firstRoll: Int, secondRoll: Int?, thirdRoll: Int?){
        if let  secondRollAvailable = secondRoll,
           let  thirdRollAvailable = thirdRoll {
            if (firstRoll > 10 || secondRollAvailable > 10 || thirdRollAvailable > 10){
                return
            }
            if ((firstRoll != 10) && (firstRoll + secondRollAvailable > 10)){
                return
            } else if ((secondRollAvailable != 10) && (thirdRollAvailable != 10) && (secondRollAvailable + thirdRollAvailable > 10)){
                return
            }
            if (bowlingGameModel.rollCount <= bowlingGameModel.tenthFrameMaxRolls){
                switch (bowlingGameModel.rollCount){
                case 0:
                    // Roll first ball of tenth frame and increase rollcount
                    rollOne = firstRoll
                    print(rollOne)
                    if (rollOne == 10){
                        bowlingGameModel.specialThrow.onNext(bowlingGameModel.strikeCondition())
                    }
                    firstThrow = true
                    calculateScore()
                    firstThrow = false
                    bowlingGameModel.rollCount += 1
                    break
                case 1:
                    // Roll second ball of tenth frame and increase rollcount
                    if (rollOne < 10){
                        rollTwo = secondRollAvailable
                    } else {
                        rollTwo = secondRollAvailable
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
                            // If roll one and two didn't produce a spare, or were not strikes, complete this frame - game is now finished
                            bowlingGameModel.frameComplete.onNext(false)
                            bowlingGameModel.rollCount += 1
                        }
                    }
                    break
                case 2:
                    // If criteria met from roll one and two, roll the third and final ball - game is now finished.
                    if (rollTwo < 10){
                        rollThree = thirdRollAvailable
                    } else {
                        rollThree = thirdRollAvailable
                    }
                    if (rollTwo + rollThree == 10 && rollTwo != 10){
                        bowlingGameModel.specialThrow.onNext(bowlingGameModel.spareCondition())
                    } else if (rollThree == 10 && rollTwo == 10){
                        bowlingGameModel.specialThrow.onNext(bowlingGameModel.strikeCondition())
                    }
                    calculateScore()
                    // Let VC know the game is finished
                    bowlingGameModel.frameComplete.onNext(false)
                    bowlingGameModel.rollCount += 1
                    break
                default:
                    break
                }
            } else {
                finishGame()
            }
        }
    }
    
    
}
