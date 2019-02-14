//
//  EquipmentViewController.swift
//  OSRS DPS Calculator
//

import UIKit

class EquipmentViewController: OSRSViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var collection: UICollectionView?
    var equipment: [Slot: [Equipment]] = [:]
    
    var gearPicker: [Slot : UIPickerView] = [:]
    
    var cellSize = CGSize()
    var halfSize = CGSize()
    
    let halfSizeIndex = [0, 4, 5, 9, 11, 13, 16, 18, 21, 23]
    
    let slotIndex: [Int: Slot] = [2:.head, 6:.back, 7:.neck, 8:.quiver, 10:.mainhand, 12:.torso, 14:.offhand, 17:.legs, 20:.hands, 22:.feet, 24:.finger]
    
    var emptySlot = UIImage()
    
    var slotImage: [Slot: UIImageView] = [:]
    
    var valueText = UILabel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Equipment.validated {
            for s in Equipment.validatedSlot {
                slotImage[s]?.image = Utilities.resizeImage(UIImage(named: String(describing: s))!, width: cellSize.width*0.9, height: cellSize.height*0.9)
                gearPicker[s]!.reloadAllComponents()
            }
            collection?.reloadItems(at: indexOf(Equipment.validatedSlot))
            updatedValue()
            Equipment.validated = false
            Equipment.validatedSlot = []
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        equipment = DataModel.data().equipment
        Equipment.callback = updatedValue

        // Do any additional setup after loading the view.
        cellSize = CGSize(width:(UIScreen.main.bounds.width-40)/4, height:(UIScreen.main.bounds.width-40)/4)
        halfSize = CGSize(width: cellSize.width/2, height: cellSize.height)
        
        emptySlot = Utilities.resizeImage(#imageLiteral(resourceName: "slot"), width: cellSize.width*0.9, height: cellSize.height*0.9)
        
        for s in Slot.initAll() {
            slotImage[s] = UIImageView(image: Utilities.resizeImage(UIImage(named: String(describing: s))!, width: cellSize.width*0.9, height: cellSize.height*0.9))
            let picker = UIPickerView()
            
            picker.delegate = self
            picker.dataSource = self
            picker.isHidden = true
            picker.layer.cornerRadius = 5
            picker.backgroundColor = .darkGray
            picker.layer.borderColor = UIColor.black.cgColor
            picker.layer.borderWidth = 3.0
            picker.center.x = view.center.x
            picker.center.y = picker.center.y + (UIScreen.main.bounds.height * 0.105) + 20
            
            view.addSubview(picker)
            gearPicker[s] = picker
        }
        
        valueText.text = "0"
        valueText.font = UIFont(name: "RuneScape-UF", size: 28)
        valueText.backgroundColor = .clear
        valueText.textColor = .yellow
        valueText.textAlignment = .center
        valueText.frame.size = CGSize(width: UIScreen.main.bounds.width-40, height: cellSize.height)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: UIScreen.main.bounds.height * 0.105, left: 19, bottom: 0, right: 19)
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        
        collection = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        collection!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collection!.delegate = self
        collection!.dataSource = self
        collection!.backgroundColor = UIColor.clear
        
        view.addSubview(collection!)
    }

    func indexOf(_ slot: Slot) -> IndexPath {
        var idx: IndexPath = IndexPath()
        
        for s in slotIndex {
            if s.value == slot {
                idx = IndexPath(item: s.key, section: 0)
                break
            }
        }
        
        return idx
    }
    
    func indexOf(_ slots: [Slot]) -> [IndexPath] {
        var idx: [IndexPath] = []
        for s in slots {
            idx.append(indexOf(s))
        }
        return idx
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 26
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        cell.contentView.backgroundColor = .clear
        
        if slotIndex.keys.contains(indexPath.item) {
            slotImage[slotIndex[indexPath.item]!]!.center = cell.contentView.center
            cell.contentView.addSubview(slotImage[slotIndex[indexPath.item]!]!)
        } else if indexPath.item == 25 {
            valueText.center = cell.contentView.center
            cell.contentView.addSubview(valueText)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if halfSizeIndex.contains(indexPath.item) {
            return halfSize
        } else if indexPath.item == 25 {
            return valueText.frame.size
        }
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for p in gearPicker {
            p.value.isHidden = true
        }
        if slotIndex.keys.contains(indexPath.item) {
            let picker = gearPicker[slotIndex[indexPath.item]!]!
            view.bringSubview(toFront: picker)
            picker.isHidden = false
        }
    }
    
    func getSlot(_ picker: UIPickerView) -> Slot? {
        for p in gearPicker {
            if p.value == picker {
                return p.key
            }
        }
        return nil
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        let s = getSlot(pickerView)
        if s == nil {
            return 0
        }
        return equipment[s!]!.count
    }
    
    private func image(_ equip: Equipment, _ slot: Slot) -> UIImage {
        var imageName = equip.name.lowercased().replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "'", with: "")
        if imageName == "empty" || imageName == "unarmed" {
            imageName = String(describing: slot)
        }
        return UIImage(named: imageName)!
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let stack = (view as? UIStackView) ?? UIStackView()
        let s = getSlot(pickerView)!
        let label = UILabel()
        label.textColor = .orange
        let img = UIImageView(image: image(equipment[s]![row], s))
        
        stack.axis = .horizontal
        stack.backgroundColor = .clear
        stack.distribution = .fill
        stack.alignment = .center
        
        if !equipment[s]![row].canActivate() {
            label.textColor = .gray
            img.alpha = 0.25
        }
        
        img.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
        let stretchingView = UIView()
        stretchingView.setContentHuggingPriority(UILayoutPriority(rawValue: 1), for: .horizontal)
        stretchingView.backgroundColor = .clear
        stretchingView.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont(name: "RuneScape-UF", size: 26)
        label.text = "    "+equipment[s]![row].name
        label.backgroundColor = .clear
        label.textAlignment = .left
        stack.addArrangedSubview(img)
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(stretchingView)

        return stack
    }
    
    func updatedValue() {
        let nf = NumberFormatter()
        nf.numberStyle = NumberFormatter.Style.decimal
        valueText.text = nf.string(from: NSNumber(value:Equipment.evaluate()))
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let s = getSlot(pickerView)!
        let wep = Weapon.equiped
        
        if equipment[s]![row].activate() {
            var updated = [indexOf(s)]
            var img = image(equipment[s]![row], s)
            
            if equipment[s]![row].name == "Unarmed" || equipment[s]![row].name == "Empty" {
                img = Utilities.resizeImage(UIImage(named: String(describing: s))!, width: cellSize.width*0.9, height: cellSize.height*0.9)
            } else {
                if img.size.width > img.size.height {
                    let ratio = cellSize.width / img.size.width
                    img = Utilities.resizeImage(img, width: cellSize.width*0.65, height: (img.size.height*ratio)*0.65)
                } else {
                    let ratio = cellSize.height / img.size.height
                    img = Utilities.resizeImage(img, width: (img.size.width*ratio)*0.65, height: cellSize.height*0.65)
                }
                img = Utilities.overlay(img, on: emptySlot)
                
                if s == .mainhand && Weapon.equiped.twoHanded && !wep.twoHanded {
                    slotImage[.offhand]?.image = Utilities.resizeImage(#imageLiteral(resourceName: "offhand"), width: cellSize.width*0.9, height: cellSize.height*0.9)
                    updated.append(indexOf(.offhand))
                } else if s == .offhand && wep.twoHanded {
                    slotImage[.mainhand]?.image = Utilities.resizeImage(#imageLiteral(resourceName: "mainhand"), width: cellSize.width*0.9, height: cellSize.height*0.9)
                    updated.append(indexOf(.mainhand))
                }
            }
            slotImage[s]?.image = img
            pickerView.isHidden = true
            collection?.reloadItems(at: updated)
            updatedValue()
            updateMetrics()
        }
    }
}
