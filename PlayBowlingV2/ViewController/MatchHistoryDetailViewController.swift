//
//  MatchHistoryDetailViewController.swift
//  PlayBowlingV2
//
//  Created by Metricell Developer on 04/04/2019.
//  Copyright © 2019 Metricell Developer. All rights reserved.
//

import UIKit

class MatchHistoryDetailViewController: UIViewController {

    // Core
    var matchDate = String()
    
    // Player One details
    @IBOutlet weak var playerOneScoreBoard: UICollectionView!
    private var playerOneCollectionViewController = ScoreboardCollectionView()
    var playerOneScore = [[Int]]()
    @IBOutlet weak var playerOneFinalScore: UILabel!
    
    // Player Two details
    @IBOutlet weak var playerTwoScoreBoard: UICollectionView!
    private var playerTwoCollectionViewController = ScoreboardCollectionView()
    var playerTwoScore = [[Int]]()
    @IBOutlet weak var playerTwoFinalScore: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerOneCollectionViewController.setupAndBindForHistory(withObtainedScores: playerOneScore, withCollectionView: playerOneScoreBoard)
        playerTwoCollectionViewController.setupAndBindForHistory(withObtainedScores: playerTwoScore, withCollectionView: playerTwoScoreBoard)
        
        guard let playerOneScoreTotal = playerOneScore.last?.last else {return}
        guard let playerTwoScoreTotal = playerTwoScore.last?.last else {return}
        playerOneFinalScore.text = "Final Score: \(playerOneScoreTotal)"
        playerTwoFinalScore.text = "Final Score: \(playerTwoScoreTotal)"
        
        self.title = matchDate
    }

}
