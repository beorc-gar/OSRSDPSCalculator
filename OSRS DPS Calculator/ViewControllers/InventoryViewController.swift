//
//  InventoryViewController.swift
//  OSRS DPS Calculator
//

import UIKit

class InventoryViewController: ModelViewController {
    override func viewDidLoad() {
        models = DataModel.data().items
        super.viewDidLoad()
    }
}
