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
    let tenthFrameMaxRolls = 3
    
    var framesSubject = PublishSubject<[[Int]]>()
    var rolls = [Int?]()
    var rollCount = 0
    var scoreCard = [Int: [Int]]()
    var frames = [[0,0,0], [0,0,0], [0,0,0], [0,0,0], [0,0,0], [0,0,0], [0,0,0], [0,0,0], [0,0,0], [0,0,0,0]]

    var standardFrame = [0,0,0]

    var totalScore = 0
}
