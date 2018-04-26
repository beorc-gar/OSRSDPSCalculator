//
//  PrayerViewController.swift
//  OSRS DPS Calculator
//
//  Created by Bronson Graansma on 2018-03-09.
//  Copyright © 2018 Bronson Graansma. All rights reserved.
//

import UIKit

class PrayerViewController: ModelViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Prayer.validated {
            collection?.reloadData()
            Prayer.validated = false
        }
    }
    
    override func viewDidLoad() {
        models = DataModel.data().prayers
        super.viewDidLoad()
    }
}
