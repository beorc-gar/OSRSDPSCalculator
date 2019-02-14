//
//  FirstViewController.swift
//  OSRS DPS Calculator
//

import UIKit

class CombatStyleViewController: OSRSViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var weaponLabel = UILabel()
    var levelLabel = UILabel()
    var stack = UIStackView()
    var collection: UICollectionView?
    var cellSize = CGSize()
    
    var bg = UIImage()
    var bg_selected = UIImage()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        weaponLabel.text = Weapon.equiped.name
        levelLabel.text = "Combat Level:  "+String(DPSCalculator.combatLevel())
        if CombatStyle.validated {
            collection?.reloadData()
            CombatStyle.validated = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        cellSize = CGSize(width:(UIScreen.main.bounds.width-40)/3, height:((UIScreen.main.bounds.width-40)/3)*(11/17))
        
        bg = Utilities.resizeImage(#imageLiteral(resourceName: "style"), width: cellSize.width, height: cellSize.height)
        bg_selected = Utilities.resizeImage(#imageLiteral(resourceName: "style_selected"), width: cellSize.width, height: cellSize.height)
        
        weaponLabel.font = UIFont(name: "RuneScape-UF", size: 26)
        weaponLabel.backgroundColor = .clear
        weaponLabel.textColor = .orange
        weaponLabel.textAlignment = .center
        weaponLabel.text = Weapon.equiped.name
        levelLabel.font = UIFont(name: "RuneScape-UF", size: 24)
        levelLabel.backgroundColor = .clear
        levelLabel.textColor = .orange
        levelLabel.textAlignment = .center
        levelLabel.text = "Combat Level:  "+String(DPSCalculator.combatLevel())
        
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.layoutMargins = UIEdgeInsets(top: UIScreen.main.bounds.height * 0.105, left: 19, bottom: 0, right: 19)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.backgroundColor = .clear
        stack.center.x = view.center.x
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = cellSize
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        
        collection = UICollectionView(frame: stack.frame, collectionViewLayout: layout)
        collection!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collection!.delegate = self
        collection!.dataSource = self
        collection!.backgroundColor = UIColor.clear
        
        weaponLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        levelLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .vertical)
        collection!.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .vertical)
        
        stack.addArrangedSubview(weaponLabel)
        stack.addArrangedSubview(levelLabel)
        stack.addArrangedSubview(collection!)
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: view.topAnchor),
            collection!.widthAnchor.constraint(equalToConstant: (cellSize.width*2)+20)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Weapon.equiped.attacks.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        for sub in cell.contentView.subviews {
            sub.removeFromSuperview()
        }
        let style = Weapon.equiped.attacks[indexPath.item]
        var img = UIImage(named: "attack_"+String(describing: style.attack))!
        
        let ratio = 1/(img.size.height / (cellSize.height*0.6))
        img = Utilities.resizeImage(img, width: ratio*img.size.width, height: ratio*img.size.height)
        
        if style.isActivated() {
            cell.contentView.backgroundColor = UIColor(patternImage: bg_selected)
        } else {
            cell.contentView.backgroundColor = UIColor(patternImage: bg)
        }
        
        let label = UILabel()
        label.font = UIFont(name: "RuneScape-UF", size: 24)
        label.backgroundColor = .clear
        label.textColor = .orange
        label.textAlignment = .center
        label.text = style.name
        
        let temp = UIStackView()
        temp.axis = .vertical
        temp.distribution = .fill
        temp.alignment = .fill
        temp.translatesAutoresizingMaskIntoConstraints = false
        temp.backgroundColor = .clear
        
        
        temp.addArrangedSubview(UIImageView(image: img))
        temp.addArrangedSubview(label)
        
        cell.contentView.addSubview(temp)
        
        NSLayoutConstraint.activate([
            temp.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            temp.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !Weapon.equiped.attacks[indexPath.item].isActivated() {
            if Weapon.equiped.attacks[indexPath.item].activate() {
                collection?.reloadData()
                updateMetrics()
            }
        }
    }
}

