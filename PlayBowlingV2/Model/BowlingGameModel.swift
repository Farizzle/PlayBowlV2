//
//  BowlingGameModel.swift
//  PlayBowlingV2
//
//  Created by Metricell Developer on 30/03/2019.
//  Copyright © 2019 Metricell Developer. All rights reserved.
//

import Foundation
import RxSwift

class BowlingGameModel {
    var frameCount = 0
    
    let totalFrames = 10
    let tenthFrameMaxRolls = 2
    
    var framesSubject = PublishSubject<[[Int]]>()
    var specialThrow = PublishSubject<Int>()
    var frameComplete = PublishSubject<Bool>()
    var rollCount = 0
    var frames = [[0,0,0], [0,0,0], [0,0,0], [0,0,0], [0,0,0], [0,0,0], [0,0,0], [0,0,0], [0,0,0], [0,0,0,0]]

    var standardFrame = [0,0,0]
    
    enum specialThrowCases : Int {
        case Strike = 0
        case Spare = 1
    }
    
    func strikeCondition() -> Int {
        return specialThrowCases.Strike.rawValue
    }
    
    func spareCondition() -> Int {
        return specialThrowCases.Spare.rawValue
    }
}
