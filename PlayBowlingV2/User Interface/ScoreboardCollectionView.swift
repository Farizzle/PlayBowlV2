//
//  ScoreboardCollectionView.swift
//  PlayBowlingV2
//
//  Created by Metricell Developer on 01/04/2019.
//  Copyright © 2019 Metricell Developer. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ScoreboardCollectionView: NSObject, UICollectionViewDelegate, UICollectionViewDataSource{
 
    private var bag = DisposeBag()
    private var viewModel: BowlingGameViewModel?
    private var scoreBoardValues = [[Int]]()
    
    func setupAndBind(passedVM: BowlingGameViewModel, withCollectionView: UICollectionView) {
        viewModel = passedVM
        withCollectionView.delegate = self
        withCollectionView.dataSource = self
        passedVM.bowlingGameModel.framesSubject.subscribe{(event) in
            guard let scoreBoard = event.element else {return}
            self.scoreBoardValues = scoreBoard
            withCollectionView.reloadData()
            }.disposed(by: bag)
        passedVM.bowlingGameModel.specialThrow.subscribe{ (event) in
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
        scoreBoardValues = passedVM.bowlingGameModel.frames
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
