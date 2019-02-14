//
//  SpellBookViewController.swift
//  OSRS DPS Calculator
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
