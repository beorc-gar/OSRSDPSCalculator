//
//  PrayerViewController.swift
//  OSRS DPS Calculator
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
