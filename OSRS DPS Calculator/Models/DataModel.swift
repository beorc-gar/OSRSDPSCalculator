//
//  Data.swift
//  OSRS DPS Calculator
//

import Foundation

class DataModel {
    var prayers:[Prayer]
    var equipment:[Slot:[Equipment]]
    var items:[Item]
    var spells:[Spell]
    var opponents:[Opponent]
    
    var tabs:[OSRSViewController]
    
    static var instance: DataModel?
    
    init() {
        if DataModel.instance == nil {
            prayers = Prayer.initAll() as! [Prayer]
            equipment = Equipment.initAll()
            items = Item.initAll() as! [Item]
            spells = Spell.initAll() as! [Spell]
            opponents = Opponent.initAll() as! [Opponent]
            tabs = [CombatStyleViewController(), StatsViewController(), SettingsViewController(), InventoryViewController(), EquipmentViewController(), PrayerViewController(), SpellBookViewController()]
            DataModel.instance = self
        } else {
            prayers = []
            equipment = [:]
            items = []
            spells = []
            opponents = []
            tabs = []
        }
    }
    
    func preload() {
        for tab in tabs {
            tab.viewDidLoad()
        }
    }
    
    class func data() -> DataModel {
        return instance!
    }
}
