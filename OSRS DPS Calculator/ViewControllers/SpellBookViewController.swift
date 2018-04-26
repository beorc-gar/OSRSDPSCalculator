//
//  SpellBookViewController.swift
//  OSRS DPS Calculator
//
//  Created by Bronson Graansma on 2018-03-09.
//  Copyright © 2018 Bronson Graansma. All rights reserved.
//

import UIKit

class SpellBookViewController: ModelViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Spell.validated {
            collection?.reloadData()
            Spell.validated = false
        }
    }

    override func viewDidLoad() {
        models = DataModel.data().spells
        modelsPerLine = 6
        super.viewDidLoad()
    }
}
