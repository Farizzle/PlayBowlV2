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
        scoreBoardValues = passedVM.bowlingGameModel.frames
    }
    
    func setupAndBindForHistory(withObtainedScores: [[Int]], withCollectionView: UICollectionView){
        self.scoreBoardValues = withObtainedScores
        withCollectionView.delegate = self
        withCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scoreBoardValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.row < 9){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StandardFrameCell", for: indexPath) as! StandardFrameCell
            return handleStandardFrameCells(cell: cell, indexPath: indexPath)
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TenthFrameCell", for: indexPath) as! TenthFrameCell
            return handleTenthFrameCell(cell: cell, indexPath: indexPath)
        }
    }
    
    private func handleStandardFrameCells(cell: StandardFrameCell, indexPath: IndexPath) -> StandardFrameCell{
        guard
            let rollOneValue = scoreBoardValues[indexPath.row].first,
            let frameScore = scoreBoardValues[indexPath.row].last
            else {
                return cell
        }
        cell.frameLabel.text = "Frame \(indexPath.row+1)"
        
        if (rollOneValue == 10){
            cell.rollOne.text = "X"
        } else {
            cell.rollOne.text = "\(rollOneValue)"
        }
        
        let rollTwoValue = scoreBoardValues[indexPath.row][1]
        if (rollOneValue != 10){
            if (rollOneValue+rollTwoValue == 10){
                cell.rollTwo.text = "/"
            } else {
                cell.rollTwo.text = "\(scoreBoardValues[indexPath.row][1])"
            }
        } else {
            cell.rollTwo.text = "-"
        }
        
        cell.frameScore.text = "\(frameScore)"
        
        return cell
    }
    
    private func handleTenthFrameCell(cell: TenthFrameCell, indexPath: IndexPath) -> TenthFrameCell{
        guard
            let rollOneValue = scoreBoardValues[indexPath.row].first,
            let frameScore = scoreBoardValues[indexPath.row].last
            else {
                return cell
        }
        cell.frameLabel.text = "Frame \(indexPath.row+1)"
        if (rollOneValue == 10){
            cell.rollOne.text = "X"
        } else {
            cell.rollOne.text = "\(rollOneValue)"
        }
        
        let rollTwoValue = scoreBoardValues[indexPath.row][1]
        
        if (rollTwoValue == 10){
            cell.rollTwo.text = "X"
        } else if (rollOneValue != 10 && (rollOneValue + rollTwoValue == 10)){
            cell.rollTwo.text = "/"
        } else {
            cell.rollTwo.text = "\(rollTwoValue)"
        }
        
        let rollThreeValue = scoreBoardValues[indexPath.row][2]
        
        if (rollThreeValue == 10){
            cell.rollThree.text = "X"
        } else if (rollTwoValue != 10 && (rollTwoValue + rollThreeValue == 10)){
            cell.rollThree.text = "/"
        } else {
            cell.rollThree.text = "\(rollThreeValue)"
        }
        
        cell.frameScore.text = "\(frameScore)"
        return cell
    }
}
