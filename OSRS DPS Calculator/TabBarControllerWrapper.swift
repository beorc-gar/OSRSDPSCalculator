//
//  TabBarControllerWrapper.swift
//  OSRS DPS Calculator
//

import Foundation
import UIKit


class TabBarControllerWrapper : UITabBarController, UITabBarControllerDelegate {
    private var w: CGFloat = 0.0
    private var h: CGFloat = 0.0
    
    override var traitCollection: UITraitCollection {
        let realTraits = super.traitCollection
        let lieTrait = UITraitCollection.init(horizontalSizeClass: .regular)
        return UITraitCollection(traitsFrom: [realTraits, lieTrait])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        w = self.tabBar.frame.width / 7
        self.tabBar.itemSpacing = w
        h = #imageLiteral(resourceName: "combat_style").size.height * (w/#imageLiteral(resourceName: "combat_style").size.width)
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = h
        self.tabBar.frame = tabFrame
        UITabBar.appearance().barTintColor = .black
        
        let combatStyle = DataModel.data().tabs[0]
        combatStyle.tabBarItem = item(#imageLiteral(resourceName: "combat_style"), #imageLiteral(resourceName: "combat_style_selected"))
        
        let stats = DataModel.data().tabs[1]
        stats.tabBarItem = item(#imageLiteral(resourceName: "stats"), #imageLiteral(resourceName: "stats_selected"))
        
        let settings = DataModel.data().tabs[2]
        settings.tabBarItem = item(#imageLiteral(resourceName: "settings"), #imageLiteral(resourceName: "settings_selected"))
        
        let inventory = DataModel.data().tabs[3]
        inventory.tabBarItem = item(#imageLiteral(resourceName: "inventory"), #imageLiteral(resourceName: "inventory_selected"))
        
        let equipment = DataModel.data().tabs[4]
        equipment.tabBarItem = item(#imageLiteral(resourceName: "equipment"), #imageLiteral(resourceName: "equipment_selected"))
        
        let prayer = DataModel.data().tabs[5]
        prayer.tabBarItem = item(#imageLiteral(resourceName: "prayer_tab"), #imageLiteral(resourceName: "prayer_selected"))
        
        let spellBook = DataModel.data().tabs[6]
        spellBook.tabBarItem = item(#imageLiteral(resourceName: "spell_book"), #imageLiteral(resourceName: "spell_book_selected"))
        
        self.viewControllers = [combatStyle, stats, settings, inventory, equipment, prayer, spellBook]
    }
    
    private func item(_ img: UIImage, _ sel_img: UIImage) -> UITabBarItem {
        return UITabBarItem(title: nil, image: Utilities.resizeImage(img, width: w, height: h), selectedImage: Utilities.resizeImage(sel_img, width: w, height: h))
    }
}
