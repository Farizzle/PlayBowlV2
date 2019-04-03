//
//  ViewController.swift
//  PlayBowlingV2
//
//  Created by Metricell Developer on 30/03/2019.
//  Copyright © 2019 Metricell Developer. All rights reserved.
//

import UIKit
import RxSwift

class BowlingGameViewController: UIViewController {
    
    // Core
    private let bag = DisposeBag()
    private var scoreBoardCollectionView = ScoreboardCollectionView()
    @IBOutlet weak var saveStateLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    private var hasGameSaved = false
    private var originalFrameXPosition = CGFloat()
    
    // Player One
    private var bowlingGame = BowlingGame.init()
    private var bowlingGameViewModel: BowlingGameViewModel?
    @IBOutlet weak var scoreBoard: UICollectionView!
    @IBOutlet weak var playerOneRoll: UIButton!
    private var playerOneFinished = false
    @IBOutlet weak var playerOneThrowLabel: UILabel!
    
    // Player Two
    private var bowlingGameTwo = BowlingGame.init()
    private var bowlingGameViewModelTwo: BowlingGameViewModel?
    @IBOutlet weak var secondPlayerScoreBoard: UICollectionView!
    @IBOutlet weak var playerTwoRoll: UIButton!
    private var playerTwoFinished = false
    @IBOutlet weak var playerTwoThrowLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get reference of starting label position
        originalFrameXPosition = playerOneThrowLabel.frame.origin.x
        // Move Special Throw labels to starting position for animation
        hideSpecialThrowAnimationLabels()
        // Setup the game
        setupGame()
    }
    
    func setupGame(){
        // Setup player one game
        bowlingGameViewModel = BowlingGameViewModel.init(withBowlingGame: bowlingGame)
        guard let initializedViewModel = bowlingGameViewModel else { return }
        scoreBoardCollectionView.setupAndBind(passedVM: initializedViewModel, withCollectionView: scoreBoard)
        switchPlayer(isSecondPlayersTurn: false)

        // Setup player two game
        bowlingGameViewModelTwo = BowlingGameViewModel.init(withBowlingGame: bowlingGameTwo)
        guard let initializedViewModelTwo = bowlingGameViewModelTwo else {return}
        scoreBoardCollectionView.setupAndBind(passedVM: initializedViewModelTwo, withCollectionView: secondPlayerScoreBoard)
        
        // Switches to player two once player ones frame is complete
        initializedViewModel.bowlingGameModel.frameComplete.subscribe{ (event) in
            self.switchPlayer(isSecondPlayersTurn: true)
        }.disposed(by: bag)
        
        // Listens for special throws from Player One
        initializedViewModel.bowlingGameModel.specialThrow.subscribe{ (event) in
            guard let specialThrowCondition = event.element else {return}
            switch specialThrowCondition{
            case 0 :
                self.strikeAnimation(wasPlayerOne: true)
                break
            case 1 :
                self.spareAnimation(wasPlayerOne: true)
                break
            default:
                break
            }
        }.disposed(by: bag)

        // Switches to player one once player ones frame is complete
        initializedViewModelTwo.bowlingGameModel.frameComplete.subscribe{ (event) in
            guard let gameInProgress = event.element else {return}
            if (gameInProgress){
                self.switchPlayer(isSecondPlayersTurn: false)
            } else {
                self.enableSaveGame()
            }
        }.disposed(by: bag)
        
        // Listens for special throws from Player Two
        initializedViewModelTwo.bowlingGameModel.specialThrow.subscribe{ (event) in
            guard let specialThrowCondition = event.element else {return}
            switch specialThrowCondition{
            case 0 :
                self.strikeAnimation(wasPlayerOne: false)
                break
            case 1 :
                self.spareAnimation(wasPlayerOne: false)
                break
            default:
                break
            }
            }.disposed(by: bag)

    }
    
    @IBAction func rollTheBall(){
        bowlingGame.rollBall()
    }
    
    @IBAction func rollBallForSecond(){
        bowlingGameTwo.rollBall()
    }
    
    private func switchPlayer(isSecondPlayersTurn: Bool){
        self.saveButton.isUserInteractionEnabled = false
        self.saveButton.setTitleColor(UIColor.gray, for: .normal)
        self.saveStateLabel.isHidden = true
        if (isSecondPlayersTurn){
            controlPlayerOneButton(enabled: false)
            controlPlayerTwoButton(enabled: true)
        } else {
            controlPlayerOneButton(enabled: true)
            controlPlayerTwoButton(enabled: false)
        }
    }
    
    private func enableSaveGame(){
        self.saveStateLabel.isHidden = false
        self.saveStateLabel.text = "Game Finished!"
        saveButton.isUserInteractionEnabled = true
        saveButton.titleLabel?.textColor = self.view.tintColor
        controlPlayerOneButton(enabled: false)
        controlPlayerTwoButton(enabled: false)
    }
    
    private func controlPlayerOneButton(enabled: Bool){
        if (enabled){
            self.playerOneRoll.isUserInteractionEnabled = true
            self.playerOneRoll.setTitleColor(self.view.tintColor, for: .normal)
        } else {
            self.playerOneRoll.isUserInteractionEnabled = false
            self.playerOneRoll.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    private func controlPlayerTwoButton(enabled: Bool){
        if (enabled){
            self.playerTwoRoll.isUserInteractionEnabled = true
            self.playerTwoRoll.setTitleColor(self.view.tintColor, for: .normal)
        } else {
            self.playerTwoRoll.isUserInteractionEnabled = false
            self.playerTwoRoll.setTitleColor(UIColor.gray, for: .normal)
        }
    }
    
    @IBAction func saveGame(_ sender: Any) {
        // Check if both players have completed the tenth frame
        if (!hasGameSaved){
            // Save both users score data to the entity "Scoreboards"
            guard let playerOneFrames = bowlingGameViewModel?.bowlingGameModel.frames else {return}
            guard let playerTwoFrames = bowlingGameViewModelTwo?.bowlingGameModel.frames else {return}
            CoreDataHelper.saveUser(entityName: "Scoreboards", playerOneScore: playerOneFrames, playerTwoScore: playerTwoFrames, timeOfMatch: Date.init())
            saveStateLabel.text = "Game saved!"
            hasGameSaved = true
        } else {
            saveStateLabel.text = "Game already saved!"
        }
    }
    
    private func strikeAnimation(wasPlayerOne: Bool){
        hideSpecialThrowAnimationLabels()
        if (wasPlayerOne){
            playerOneThrowLabel.text = "STRIKE!"
            UIView.animate(withDuration: 3.0, delay: 0, options: [.curveEaseIn], animations: {
                self.takeLabelToOtherSide(label: self.playerOneThrowLabel)
            }, completion: nil)
        } else {
            playerTwoThrowLabel.text = "STRIKE!"
            UIView.animate(withDuration: 3.0, delay: 0, options: [.curveEaseIn], animations: {
                self.takeLabelToOtherSide(label: self.playerTwoThrowLabel)
            }, completion: nil)
        }
    }
    
    private func spareAnimation(wasPlayerOne: Bool){
        hideSpecialThrowAnimationLabels()
        if (wasPlayerOne){
            playerOneThrowLabel.text = "SPARE"
            UIView.animate(withDuration: 3.0, delay: 0, options: [.curveEaseIn], animations: {
                self.takeLabelToOtherSide(label: self.playerOneThrowLabel)
            }, completion: nil)
        } else {
            playerTwoThrowLabel.text = "SPARE"
            UIView.animate(withDuration: 3.0, delay: 0, options: [.curveEaseIn], animations: {
                self.takeLabelToOtherSide(label: self.playerTwoThrowLabel)
            }, completion: nil)
        }
    }
    
    private func hideSpecialThrowAnimationLabels(){
        playerOneThrowLabel.frame = CGRect.init(x: self.view.frame.size.width + 10,
                                                y: playerOneThrowLabel.frame.origin.y,
                                                width: playerOneThrowLabel.frame.size.width,
                                                height: playerOneThrowLabel.frame.height)
        playerTwoThrowLabel.frame = CGRect.init(x: self.view.frame.size.width + 10,
                                                y: playerTwoThrowLabel.frame.origin.y,
                                                width: playerTwoThrowLabel.frame.size.width,
                                                height: playerTwoThrowLabel.frame.height)
    }
    
    private func takeLabelToOtherSide(label: UIView){
        label.frame = CGRect.init(x: self.view.frame.origin.x - label.frame.size.width,
                                                y: label.frame.origin.y,
                                                width: label.frame.size.width,
                                                height: label.frame.height)
    }
}

