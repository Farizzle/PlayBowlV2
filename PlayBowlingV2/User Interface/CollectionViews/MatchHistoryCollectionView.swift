//
//  MatchHistoryCollectionView.swift
//  PlayBowlingV2
//
//  Created by Metricell Developer on 03/04/2019.
//  Copyright © 2019 Metricell Developer. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MatchHistoryCollectionView : NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var loadedData = [NSManagedObject]()
    private var viewController = UIViewController()
    
    func setupAndBind(withViewController: UIViewController, withCollectionView: UICollectionView){
        loadedData = CoreDataHelper.loadCoreData(entityName: "Scoreboards")
        viewController = withViewController
        withCollectionView.delegate = self
        withCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadedData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MatchHistoryCell", for: indexPath) as! MatchHistoryCell
        let playerOneScore = loadedData[indexPath.row].value(forKey: "playerOneScore") as! Data
        let playerTwoScore = loadedData[indexPath.row].value(forKey: "playerTwoScore") as! Data
        let matchDate = loadedData[indexPath.row].value(forKey: "matchDate") as! Date
        
        do {
        let playerOneScoreConverted = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(playerOneScore) as! [[Int]]
            guard let finalPlayerOneScore = playerOneScoreConverted.last?.last else {return cell}
            cell.playerOneScore.text = "Final Score: \(finalPlayerOneScore)"
        let playerTwoScoreConverted = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(playerTwoScore) as! [[Int]]
            guard let finalPlayerTwoScore = playerTwoScoreConverted.last?.last else {return cell}
            cell.playerTwoScore.text = "Final Score: \(finalPlayerTwoScore)"
            cell.matchDate.text = matchDate.toString(withFormat: "yyyy-MM-dd HH:mm:ss")
        } catch {
            print("Failed converting scores to Int array")
        }

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playerOneScore = loadedData[indexPath.row].value(forKey: "playerOneScore") as! Data
        let playerTwoScore = loadedData[indexPath.row].value(forKey: "playerTwoScore") as! Data
        let matchDate = loadedData[indexPath.row].value(forKey: "matchDate") as! Date
        
        do {
            let playerOneScoreConverted = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(playerOneScore) as! [[Int]]
            let playerTwoScoreConverted = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(playerTwoScore) as! [[Int]]
            
            let historyDetails = viewController.storyboard?.instantiateViewController(withIdentifier: "MatchHistoryDetailViewController") as! MatchHistoryDetailViewController
            
            historyDetails.matchDate = matchDate.toString(withFormat: "yyyy-MM-dd")
            historyDetails.playerOneScore = playerOneScoreConverted
            historyDetails.playerTwoScore = playerTwoScoreConverted
            
            viewController.navigationController?.pushViewController(historyDetails, animated: true)
        } catch {
            print("Failed converting scores to Int array")
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: viewController.view.frame.size.width, height: 120)
    }


    
}
