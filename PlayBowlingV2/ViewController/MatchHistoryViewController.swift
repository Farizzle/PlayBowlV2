//
//  MatchHistoryViewController.swift
//  PlayBowlingV2
//
//  Created by Metricell Developer on 03/04/2019.
//  Copyright © 2019 Metricell Developer. All rights reserved.
//

import UIKit
import CoreData

class MatchHistoryViewController: UIViewController {
    
    private var scoreBoards:[NSManagedObject] = []
    @IBOutlet weak var matchHistoryCollectionView: UICollectionView!
    private var matchHistoryCollectionViewController = MatchHistoryCollectionView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        matchHistoryCollectionViewController.setupAndBind(withCollectionView: matchHistoryCollectionView)
    }

}
