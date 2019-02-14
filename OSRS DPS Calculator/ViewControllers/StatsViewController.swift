//
//  SecondViewController.swift
//  OSRS DPS Calculator
//

import UIKit

class StatsViewController: OSRSViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    var collection: UICollectionView? = nil
    
    var originalImages: [String: UIImage] = [:]
    
    var attackImage: UIImageView = UIImageView()
    var strengthImage: UIImageView = UIImageView()
    var defenceImage: UIImageView = UIImageView()
    var rangingImage: UIImageView = UIImageView()
    var magicImage: UIImageView = UIImageView()
    var hitpointsImage: UIImageView = UIImageView()
    var slayerImage: UIImageView = UIImageView()
    var prayerImage: UIImageView = UIImageView()
    var agilityImage: UIImageView = UIImageView()
    
    var cellSize: CGSize = CGSize()
    var nameTextBox: UITextField = UITextField()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Stats.validated {
            collection?.reloadData()
            Stats.validated = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        for stat in Stats.stats {
            originalImages[stat] = Utilities.resizeImage(#imageLiteral(resourceName: stat), width: (UIScreen.main.bounds.width-40)/3, height: #imageLiteral(resourceName: stat).size.height*(((UIScreen.main.bounds.width-40)/3)/#imageLiteral(resourceName: stat).size.width))
        }
        
        cellSize = originalImages[Stats.stats[0]]!.size
        nameTextBox = UITextField(frame: CGRect(x: 0, y: 0, width: (UIScreen.main.bounds.width-40), height: cellSize.height*(((UIScreen.main.bounds.width-40)/3)/cellSize.width)))

        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: UIScreen.main.bounds.height * 0.105, left: 19, bottom: 0, right: 19)
        layout.itemSize = cellSize
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        
        collection = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collection!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        collection!.delegate = self
        collection!.dataSource = self
        collection!.backgroundColor = UIColor.clear
        
        nameTextBox.placeholder = "rsn"
        nameTextBox.text = Stats.name
        nameTextBox.font = UIFont(name: "RuneScape-UF", size: 32)
        nameTextBox.autocorrectionType = .no
        nameTextBox.keyboardType = .default
        nameTextBox.returnKeyType = .done
        nameTextBox.contentVerticalAlignment = .center
        nameTextBox.borderStyle = .roundedRect
        nameTextBox.backgroundColor = .darkGray
        nameTextBox.textColor = .yellow
        nameTextBox.tintColor = .yellow
        nameTextBox.textAlignment = .center
        nameTextBox.delegate = self
        
        setLevels()
        
        view.addSubview(collection!)
    }

    private func setLevels() {
        updateMetrics()
        collection!.reloadData()
    }
    
    func lookupComplete(_ success: Bool) {
        if success {
            DispatchQueue.main.async {
                self.setLevels()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)
        
        let numerator = CGPoint(x: cellSize.width*0.5329, y:  cellSize.height*0.2325)
        let denominator = CGPoint(x: cellSize.width*0.7303, y:  cellSize.height*0.6075)
        
        if indexPath.item != 9 {
            let img = UIImageView(image: Utilities.textOnImage(drawText: String(Stats.get(Stats.stats[indexPath.item])),inImage: Utilities.textOnImage(drawText: String(Stats.getBoosted(Stats.stats[indexPath.item])), inImage: originalImages[Stats.stats[indexPath.item]]!, atPoint: numerator, size: 22), atPoint: denominator, size: 22))
            cell.contentView.addSubview(img)
        } else {
            cell.contentView.addSubview(nameTextBox)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item != 9 {return cellSize}
        return nameTextBox.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 9 {
            nameTextBox.becomeFirstResponder()
            return
        }
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = Stats.stats[indexPath.item]+" level"
            textField.keyboardType = .numberPad
            textField.textAlignment = .center
        })
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: { action in self.statInputHandler(Stats.stats[indexPath.item], alert.textFields![0].text)}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text != nil {
            Stats.lookup(textField.text!, lookupComplete)
        }
        textField.resignFirstResponder()
        return true
    }
    
    func statInputHandler(_ statName: String, _ userInput: String?) {
        if userInput == nil {return}
        let input = userInput!.replacingOccurrences( of:"[^0-9]", with: "", options: .regularExpression)
        if input.count == 0 {return}
        
        var level = Int(userInput!)!
        
        if level < 1 {
            level = 1
        } else if level > 99 {
            level = 99
        }
        
        Stats.set(statName, level)
        setLevels()
    }
}

