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
    var bowling = Bowling.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bowlingGameViewModel = BowlingGameViewModel.init(withBowlingGame: bowlingGame)
        guard let initializedViewModel = bowlingGameViewModel else { return }
        initializedViewModel.bowlingGameModel.framesSubject.map({value -> String in
            if (self.bowlingGame.wasStrike()){
                print(value)
                return "STRIKE"
            } else if (self.bowlingGame.wasSpare()){
                print(value)
                return "SPARE"
            } else {
                print(value)
                return String(describing: value)
            }
        }).subscribe{(event) in
//            guard let rollValue = event.element else {return}
//            print(rollValue)

            // On second throw calculate current frameScore
            if (initializedViewModel.bowlingGameModel.rollCount % 2 != 0){
                print(initializedViewModel.calculateFrameScore())
            }
        }.disposed(by: bag)
        
    }
    
    @IBAction func rollTheBall(){
        bowlingGame.rollBall()
    }
    


}

