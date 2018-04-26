//
//  OSRSViewController.swift
//  OSRS DPS Calculator
//
//  Created by Bronson Graansma on 2018-03-10.
//  Copyright © 2018 Bronson Graansma. All rights reserved.
//

import Foundation
import UIKit

class OSRSViewController: UIViewController {
    let dpsLabel = UILabel()
    let maxLabel = UILabel()
    let hitLabel = UILabel()
    
    static var background: UIImage = {
        let img = Utilities.resizeImage(#imageLiteral(resourceName: "background"), width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - (( #imageLiteral(resourceName: "combat_style").size.height * ((UIScreen.main.bounds.width / 7)/#imageLiteral(resourceName: "combat_style").size.width))*0.92))
        return img
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMetrics()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: OSRSViewController.background)
        
        let temp = UIStackView()
        temp.axis = .horizontal
        temp.distribution = .fill
        temp.alignment = .fill
        temp.spacing = 25
        temp.translatesAutoresizingMaskIntoConstraints = false
        temp.layoutMargins = UIEdgeInsets(top: 10, left: 19, bottom: 0, right: 19)
        temp.isLayoutMarginsRelativeArrangement = true
        temp.backgroundColor = .clear
        
        for label in [dpsLabel, maxLabel, hitLabel] {
            label.font = UIFont(name: "RuneScape-UF", size: 28)
            label.backgroundColor = .clear
            label.textColor = .yellow
            label.textAlignment = .left
            temp.addArrangedSubview(label)
        }
        
        view.addSubview(temp)
        
        NSLayoutConstraint.activate([
            temp.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        updateMetrics()
    }
    
    
    
    func updateMetrics() {
        dpsLabel.text = "dps:  "+String(format: "%.4f", DPSCalculator.dps())
        maxLabel.text = "max:  "+String(DPSCalculator.MAX)
        hitLabel.text = "hit:  "+String(format: "%.1f", DPSCalculator.HIT*100)+"%"
    }
}
