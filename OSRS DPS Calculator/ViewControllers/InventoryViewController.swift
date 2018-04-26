//
//  InventoryViewController.swift
//  OSRS DPS Calculator
//
//  Created by Bronson Graansma on 2018-03-09.
//  Copyright © 2018 Bronson Graansma. All rights reserved.
//

import UIKit

class InventoryViewController: ModelViewController {
    override func viewDidLoad() {
        models = DataModel.data().items
        super.viewDidLoad()
    }
}
