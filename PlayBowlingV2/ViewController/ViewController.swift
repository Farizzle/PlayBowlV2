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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bowlingGameViewModel = BowlingGameViewModel.init(withBowlingGame: bowlingGame)
        guard let initializedViewModel = bowlingGameViewModel else { return }
        initializedViewModel.bowlingGameModel.framesSubject.subscribe{(event) in
            guard let scoreBoard = event.element else {return}
            print(scoreBoard)
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
        
    }
    
    @IBAction func rollTheBall(){
        bowlingGame.rollBall()
    }
    


}

