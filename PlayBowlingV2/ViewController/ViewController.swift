//
//  ViewController.swift
//  PlayBowlingV2
//
//  Created by Metricell Developer on 30/03/2019.
//  Copyright © 2019 Metricell Developer. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    private let bag = DisposeBag()
    private var bowlingGame = BowlingGame.init()
    private var bowlingGameViewModel: BowlingGameViewModel?
    @IBOutlet weak var scoreBoard: UICollectionView!
    private var scoreBoardCollectionView = ScoreboardCollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bowlingGameViewModel = BowlingGameViewModel.init(withBowlingGame: bowlingGame)
        guard let initializedViewModel = bowlingGameViewModel else { return }
        scoreBoardCollectionView.setupAndBind(passedVM: initializedViewModel, withCollectionView: scoreBoard)
    }
    
    @IBAction func rollTheBall(){
        bowlingGame.rollBall()
    }

}

