//
//  ViewController.swift
//  PlayBowlingV2
//
//  Created by Metricell Developer on 30/03/2019.
//  Copyright © 2019 Metricell Developer. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let bag = DisposeBag()
    private var bowlingGame = BowlingGame.init()
    private var bowlingGameViewModel: BowlingGameViewModel?
    @IBOutlet weak var scoreBoard: UICollectionView!
    private var scoreBoardValues = [[Int]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bowlingGameViewModel = BowlingGameViewModel.init(withBowlingGame: bowlingGame)
        guard let initializedViewModel = bowlingGameViewModel else { return }
        initializedViewModel.bowlingGameModel.framesSubject.subscribe{(event) in
            guard let scoreBoard = event.element else {return}
            self.scoreBoardValues = scoreBoard
            self.scoreBoard.reloadData()
        }.disposed(by: bag)
        initializedViewModel.bowlingGameModel.specialThrow.subscribe{ (event) in
            guard let specialThrowCondition = event.element else {return}
            switch specialThrowCondition{
            case 0 :
                print("Strike")
                break
            case 1 :
                print("Spare")
                break
            default:
                break
            }
        }.disposed(by: bag)
        scoreBoardValues = initializedViewModel.bowlingGameModel.frames
        scoreBoard.delegate = self
    }
    
    @IBAction func rollTheBall(){
        bowlingGame.rollBall()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.row < 9){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StandardFrameCell", for: indexPath) as! StandardFrameCell
            guard
                let rollOneValue = scoreBoardValues[indexPath.row].first,
                let frameScore = scoreBoardValues[indexPath.row].last
            else {
                return cell
            }
            cell.frameLabel.text = "Frame \(indexPath.row+1)"
            cell.rollOne.text = "\(rollOneValue)"
            cell.rollTwo.text = "\(scoreBoardValues[indexPath.row][1])"
            cell.frameScore.text = "\(frameScore)"
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TenthFrameCell", for: indexPath) as! TenthFrameCell
            guard
                let rollOneValue = scoreBoardValues[indexPath.row].first,
                let frameScore = scoreBoardValues[indexPath.row].last
                else {
                    return cell
            }
            cell.frameLabel.text = "Frame \(indexPath.row+1)"
            cell.rollOne.text = "\(rollOneValue)"
            cell.rollTwo.text = "\(scoreBoardValues[indexPath.row][1])"
            cell.rollThree.text = "\(scoreBoardValues[indexPath.row][2])"
            cell.frameScore.text = "\(frameScore)"
            
            return cell
        }
    }

}

