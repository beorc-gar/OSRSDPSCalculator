//
//  SettingsViewController.swift
//  OSRS DPS Calculator
//
//  Created by Bronson Graansma on 2018-03-09.
//  Copyright © 2018 Bronson Graansma. All rights reserved.
//

import UIKit

class SettingsViewController: OSRSViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var opponents: [Model] = []
    var opponentDropDown: UIButton = UIButton(type: .roundedRect)
    var taskCheckBox: UIButton = UIButton(type: .custom)
    var stack: UIStackView = UIStackView()
    
    var dropDown: UIPickerView = UIPickerView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Opponent.validated {
            opponentDropDown.setTitle("Opponent...", for: .normal)
            dropDown.reloadAllComponents()
            Opponent.validated = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        opponents = DataModel.data().opponents
        
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 50
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.layoutMargins = UIEdgeInsets(top: UIScreen.main.bounds.height * 0.105, left: 19, bottom: 0, right: 19)
        stack.isLayoutMarginsRelativeArrangement = true
        
        let size = CGSize(width: UIScreen.main.bounds.width/10, height: UIScreen.main.bounds.width/10)
        
        taskCheckBox.setImage(Utilities.resizeImage(#imageLiteral(resourceName: "checkbox"), width: size.width, height: size.height), for: .normal)
        taskCheckBox.setImage(Utilities.resizeImage(#imageLiteral(resourceName: "checkbox_checked"), width: size.width, height: size.height), for: .selected)
        taskCheckBox.addTarget(self, action: #selector(taskToggle), for: .touchUpInside)
        taskCheckBox.semanticContentAttribute = .forceLeftToRight
        taskCheckBox.setTitle("On Slayer Task", for: .normal)
        taskCheckBox.backgroundColor = .clear
        taskCheckBox.titleLabel?.font = UIFont(name: "RuneScape-UF", size: 26)!
        taskCheckBox.setTitleColor(.orange, for: .normal)
        taskCheckBox.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: ((self.view.frame.size.width*0.7)-size.width)-25)
        
        opponentDropDown.layer.borderColor = UIColor.black.cgColor
        opponentDropDown.layer.borderWidth = 3.0
        opponentDropDown.setTitle("Opponent...", for: .normal)
        opponentDropDown.backgroundColor = .darkGray
        opponentDropDown.titleLabel?.font = UIFont(name: "RuneScape-UF", size: 26)!
        opponentDropDown.addTarget(self, action: #selector(opponentSelection), for: .touchUpInside)
        opponentDropDown.tintColor = .orange
        opponentDropDown.setImage(Utilities.resizeImage(#imageLiteral(resourceName: "drop_arrow"), width: size.width, height: size.height), for: .normal)
        opponentDropDown.semanticContentAttribute = .forceRightToLeft
        opponentDropDown.imageEdgeInsets = UIEdgeInsets(top: 0, left: ((self.view.frame.size.width*0.7)-size.width)-25, bottom: 0, right: 0)
        opponentDropDown.layer.cornerRadius = 5
        
        dropDown.delegate = self
        dropDown.dataSource = self
        dropDown.isHidden = true
        dropDown.layer.cornerRadius = 5
        dropDown.backgroundColor = .darkGray
        dropDown.layer.borderColor = UIColor.black.cgColor
        dropDown.layer.borderWidth = 3.0
        dropDown.center.x = view.center.x
        dropDown.center.y = dropDown.center.y + (UIScreen.main.bounds.height * 0.105) + 20
        
        stack.addArrangedSubview(opponentDropDown)
        stack.addArrangedSubview(taskCheckBox)
        view.addSubview(stack)
        view.addSubview(dropDown)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            opponentDropDown.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            taskCheckBox.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7)
        ])
    }

    @objc func taskToggle() {
        Opponent.onTask = !Opponent.onTask
        taskCheckBox.isSelected = Opponent.onTask
        updateMetrics()
    }
    
    @objc func opponentSelection() {
        self.dropDown.isHidden = false
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return opponents.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        
        label.font = UIFont(name: "RuneScape-UF", size: 26)
        label.text = "    "+opponents[row].name
        label.textColor = .orange
        label.tintColor = .orange
        if !opponents[row].canActivate() {
            label.textColor = .gray
            label.tintColor = .gray
        }
        label.backgroundColor = .clear
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if opponents[row].activate() {
            opponentDropDown.setTitle(opponents[row].name, for: .normal)
            self.dropDown.isHidden = true
            updateMetrics()
        }
    }
}
