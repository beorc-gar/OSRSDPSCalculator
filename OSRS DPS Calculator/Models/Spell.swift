//
//  Spell.swift
//  OSRS DPS Calculator
//
//  Created by Bronson Graansma on 2018-03-13.
//  Copyright © 2018 Bronson Graansma. All rights reserved.
//

import Foundation

class Spell: Model {
    var damage: Int
    var level: Int
    
    var staff: [String]?
    var type: SpellType
    
    static var selected: Spell?
    static var validated: Bool = false
    
    init(id: Int, damage: Int, name: String, level: Int, staff: [String]?, type: SpellType) {
        self.damage = damage
        self.level = level
        self.staff = staff
        self.type = type
        super.init(id, name)
    }
    
    func spellBook() -> String {
        if name.lowercased().range(of: "ice ") != nil || name.lowercased().range(of: "smoke ") != nil || name.lowercased().range(of: "shadow ") != nil || name.lowercased().range(of: "blood ") != nil {
            return "ancient"
        }
        return "standard"
    }
    
    override class func validate() {
        if selected != nil && !selected!.canActivate() {
            selected!.deactivate()
        }
        validated = true
    }
    
    override func isActivated() -> Bool {
        if Spell.selected == nil {return false}
        return Spell.selected?.id == id
    }
    
    override func canActivate() -> Bool {
        if Stats.getBoosted("magic") < level {
            return false
        } else if type == .slayer && Stats.get("slayer") < 55 {
            return false
        }  else if type == .undead && !Opponent.selected!.undead {
            
            return false
        } else if staff != nil {
            for s in staff! {
                if Equipment.isActivated(s, .mainhand) {
                    return true
                }
            }
            return false
        }
        return true
    }
    
    override func activate() -> Bool {
        if canActivate() == false {return false}
        
        Spell.selected = self
        return true
    }
    
    override func deactivate() {
        if isActivated() {
            Spell.selected = nil
        }
    }
    
    func getDamage() -> Int {
        if type == .slayer && Opponent.onTask {
            if Equipment.isActivated("Slayer's staff", .mainhand) {
                return Int((Float(Stats.getBoosted("magic"))/10)+10)
            } else if Equipment.isActivated("Slayer's staff (e)", .mainhand) {
                return Int((Float(Stats.getBoosted("magic"))/6)+13)
            }
        } else if type == .god && Stats.getBoosted("magic") >= 80 {
            var capes: [String] = []
            switch name {
            case "saradomin_strike":
                capes = ["Saradomin cape", "Imbued saradomin cape", "Saradomin max cape"]
            case "claws_of_guthix":
                capes = ["Guthix cape", "Imbued guthix cape", "Guthix max cape"]
            case "flames_of_zamorak":
                capes = ["Zamorak cape", "Imbued zamorak cape", "Zamorak max cape"]
            default:
                capes = []
            }
            
            if capes.contains((Equipment.worn[.back]?.name)!) {
                return damage + 10
            }
        } else if type == .bolt && Equipment.worn[.hands]?.name == "Chaos gauntlets" {
            return damage + 3
        }
        return damage
    }
    
    override class func initAll() -> [Model] {
        var spells: [Spell] = []
        
        if let path = Bundle.main.path(forResource: "spells", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, [Dictionary<String, Any>]>, let spellDatas = jsonResult["spells"] {
                    
                    var i = 0
                    for spellData in spellDatas {
                        let n: String = spellData["name"] as! String
                        let l: Int = spellData["req"] as! Int
                        let d: Int = spellData["damage"] as! Int
                        var t: SpellType = .normal
                        let s: [String]? = spellData["staff"] as? [String]
                        
                        if spellData["god"] != nil {
                            t = .god
                        }
                        if spellData["undead"] != nil {
                            t = .undead
                        }
                        if spellData["slayer"] != nil {
                            t = .slayer
                        }
                        if spellData["bolt"] != nil {
                            t = .bolt
                        }
                        
                        spells.append(Spell(id: i, damage: d, name: n, level: l, staff: s, type: t))
                        i += 1
                    }
                    
                }
            } catch {
                print(error)
            }
        }
        
        return spells
    }
}

enum SpellType {
    case normal
    case god
    case slayer
    case undead
    case bolt
}
