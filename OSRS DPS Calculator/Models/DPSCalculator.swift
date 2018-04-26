//
//  DPSCalculator.swift
//  OSRS DPS Calculator
//
//  Created by Bronson Graansma on 2018-03-11.
//  Copyright © 2018 Bronson Graansma. All rights reserved.
//


// TODO special attacks, and castle wars, and nmz
//      combatstyle          settings         settings and items

import Foundation

class DPSCalculator {
    static var MAX: Int   = 1
    static var DPS: Float = 0.9
    static var HIT: Float = 0.9
    
    static let setBonuses: [String: Int] = [
        "void": 4,
        "verac": 4,
        "dharok": 4
    ]
    
    static func dps() -> Float {
        if CombatStyle.selected?.type == .ranged && Equipment.worn[.quiver]?.name == "Empty" && Weapon.equiped.name != "Crystal bow" {
            return 0
        } else if CombatStyle.selected?.type == .magic && Spell.selected == nil {
            return 0
        }
        var speed = Weapon.equiped.speed
        if CombatStyle.selected?.style == .rapid {
            speed -= 1
        }
        HIT = hitChance()
        MAX = maxHit()
        DPS = HIT * averageHit(MAX) * (1/speed)
        return DPS
    }
    
    static func maxHit() -> Int {
        var hit: Float = 1
        
        switch CombatStyle.selected!.type {
        case .melee:
            hit = floor((0.5 + (Float(strength()) * Float(strengthBonus()+64) / 640)) * strengthEffect())
            
            if Equipment.worn[.neck]!.name.range(of: "Salve amulet") == nil && Opponent.onTask && (Equipment.worn[.head]!.name == "Slayer helmet" || Equipment.worn[.head]!.name == "Slayer helmet (i)" || Equipment.worn[.head]!.name == "Black mask" || Equipment.worn[.head]!.name == "Black mask (i)") {
                hit = floor(hit * (7/6))
            }
            
            if setBonus() == "verac" {
                hit += 1
            }
        case .magic:
            hit = floor(magic() * magicEffect())
            
            if Equipment.worn[.offhand]!.name == "Tome of fire" && Spell.selected != nil && Spell.selected!.name.lowercased().range(of: "fire") != nil {
                hit = floor(hit * 1.5)
            }
            
            if Equipment.worn[.neck]!.name.range(of: "Salve amulet (") == nil && Opponent.onTask && (Equipment.worn[.head]!.name == "Slayer helmet (i)" || Equipment.worn[.head]!.name == "Black mask (i)") {
                hit = floor(hit * 1.15)
            }
        case .ranged:
            hit = floor((0.5 + (Float(ranged()) * Float(rangedBonus()+64) / 640)) * rangedEffect())
            
            if Equipment.worn[.neck]!.name.range(of: "Salve amulet (") == nil && Opponent.onTask && (Equipment.worn[.head]!.name == "Slayer helmet (i)" || Equipment.worn[.head]!.name == "Black mask (i)") {
                hit = floor(hit * 1.15)
            }
            
            if !Equipment.isActivated("Crystal bow", .mainhand) {
                switch Equipment.worn[.quiver]!.name {
                case "Dragonstone bolts (e)":
                    hit += floor(Float(Stats.getBoosted("ranging")) * (1/5))
                case "Opal bolts (e)":
                    hit += floor(Float(Stats.getBoosted("ranging")) * (1/10))
                case "Pearl bolts (e)":
                    hit += floor(Float(Stats.getBoosted("ranging")) * (1/15)) // or 1/20?
                case "Empty":
                    hit = 0
                default: ()
                }
            }
        default:()
        }

        return Int(hit)
    }
    
    static func combatLevel() -> Int {
        let base = 0.25*(Float(Stats.get("defence")) + Float(Stats.get("hitpoints")) + floor(Float(Stats.get("prayer")/2)))
        
        let melee = 0.325*Float(Stats.get("attack") + Stats.get("strength"))
        let range = 0.325*(floor(Float(Stats.get("ranging")/2)) + Float(Stats.get("ranging")))
        let mage = 0.325*(floor(Float(Stats.get("magic")/2)) + Float(Stats.get("magic")))
        
        return Int(floor(base + max(melee, max(range, mage))))
    }
    
    static func setBonus() -> String {
        for s in setBonuses {
            var n = 0
            for w in Equipment.worn {
                if w.value.setEffect == s.key {
                    n += 1
                }
            }
            if n >= s.value {
                if s.key == "void" {
                    var void = "void"
                    switch Equipment.worn[.head]!.name {
                        case "Void melee helm":
                            void += " melee"
                        case "Void mage helm":
                            void += " mage"
                        case "Void ranger helm":
                            void += " ranged"
                        default: ()
                    }
                    if Equipment.worn[.torso]!.name.range(of:"Elite ") != nil && Equipment.worn[.legs]!.name.range(of:"Elite ") != nil {
                        void = "elite " + void
                    }
                    return void
                }
                return s.key
            }
        }
        return ""
    }
    
    static func strengthBonus() -> Int {
        var bonus = 0
        
        for w in Equipment.worn {
            bonus += w.value.strength
        }
        
        return bonus
    }
    
    static func attackBonus(_ type: AttackType) -> Int {
        var bonus = 0

        for w in Equipment.worn {
            if w.value.stats[type] != nil {
                bonus += w.value.stats[type]!
            }
        }
        
        return bonus
    }
    
    static func rangedBonus() -> Int {
        var bonus = 0
        
        for w in Equipment.worn {
            bonus += w.value.rangedStrength
        }
        
        if Equipment.isActivated("Crystal bow", .mainhand) {
            // not applicable to toxic blowpipe because darts will be artificially in the quiver slot
            bonus -= Equipment.worn[.quiver]!.rangedStrength
        }
        
        return bonus
    }
    
    static func magicBonus() -> Int {
        var bonus = 0
        
        for w in Equipment.worn {
            bonus += w.value.stats[.magic]!
        }
        
        return bonus
    }
    
    static func strengthEffect() -> Float {
        var mult: Float = 1
        
        switch Equipment.worn[.neck]!.name {
        case "Salve amulet", "Salve amulet (i)":
            mult += 1/6
        case "Salve amulet (e)", "Salve amulet (ei)":
            mult += 0.2
        case "Berserker necklace":
            if ["Tzhaar-ket-om", "Tzhaar-ket-em", "Toktz-xil-ak", "Toktz-mej-tal", "Toktz-xil-et"].contains(Weapon.equiped.name) {
                mult += 0.2
            }
        default:()
        }
        
        if Opponent.selected?.type == .demon {
            if Equipment.isActivated("Darklight", .mainhand) {
                mult += 0.6
            } else if Equipment.isActivated("Arclight", .mainhand) {
                mult += 0.7
            }
        }
        
        if Equipment.isActivated("Keris", .mainhand) {
            if Opponent.selected?.type == .kalphite {
                mult += 2
            } else {
                mult += 1/3
            }
        } else if Equipment.isActivated("Gadderhammer", .mainhand) {
            if Opponent.selected?.type == .shade {
                mult += 1
            } else {
                mult += 0.25
            }
        } else if Equipment.isActivated("Armadyl Godsword", .mainhand) {
            mult += 0.25
        } else if Equipment.isActivated("Bandos Godsword", .mainhand) {
            mult += 0.1
        }
        
        switch setBonus() {
        case "dharok":
            mult += (Float(Stats.get("hitpoints") - Stats.getBoosted("hitpoints"))/100) * (Float(Stats.get("hitpoints"))/100)
        case "void melee", "elite void melee":
            mult += 0.1
        default: ()
        }
        
        return mult
    }
    
    static func attackEffect() -> Float {
        var mult: Float = 1
        
        if Equipment.isActivated("Twisted bow", .mainhand) {
            let mage: Float = Float(Opponent.selected!.combatStats["magic"]!)
            let first: Float = floor((3*mage-10)/100)
            let second: Float = floor(pow(0.3*mage-100, 2)/100)
            let last: Float = (140 + first - second) / 100
            
            mult += last - 1
        } else if Opponent.selected?.type == .demon && Equipment.isActivated("Arclight", .mainhand) {
            mult += 0.7
        } else if Opponent.selected?.type == .dragon && Equipment.isActivated("Dragon hunter crossbow", .mainhand) {
            mult += 0.3
        } else if CombatStyle.selected!.type == .magic && Spell.selected != nil && Spell.selected!.spellBook() == "standard" && Equipment.worn[.mainhand]!.name.lowercased().range(of: "smoke") != nil && Equipment.worn[.mainhand]!.name.lowercased().range(of: "staff") != nil {
            mult += 0.1
        }
        
        return mult
    }
    
    static func rangedEffect() -> Float {
        var mult: Float = 1
        
        switch Equipment.worn[.neck]!.name {
        case "Salve amulet (i)":
            mult += 0.15
        case "Salve amulet (ei)":
            mult += 0.2
        default:()
        }
        
        if Opponent.selected?.type == .dragon && Equipment.isActivated("Dragon hunter crossbow", .mainhand) {
            mult += 0.3
        } else if Equipment.isActivated("Twisted bow", .mainhand) {
            let mage: Float = Float(Opponent.selected!.combatStats["magic"]!)
            let first: Float = floor((3*mage-14)/100)
            let second: Float = floor(pow(0.3*mage-140, 2)/100)
            let last: Float = (250 + first - second) / 100
            
            mult += last - 1
        }
        
        if !Equipment.isActivated("Crystal bow", .mainhand) {
            switch Equipment.worn[.quiver]!.name {
            case "Diamond bolts (e)":
                mult += 0.15
            case "Onyx bolts (e)":
                mult += 0.2
            case "Empty":
                return 0
            default: ()
            }
        }
        
        switch setBonus() {
        case "void ranged":
            mult += 0.1
        case "elite void ranged":
            mult += 0.125
        default: ()
        }
        
        return mult
    }
    
    static func magicEffect() -> Float {
        var mult: Float = 1
        
        for w in Equipment.worn {
            mult += Float(w.value.magicDamage)/100
        }
        if Spell.selected != nil && Spell.selected!.spellBook() == "standard" && Weapon.equiped.name.lowercased().range(of: "smoke") != nil && Weapon.equiped.name.lowercased().range(of: "staff") != nil {
            mult += 0.1
        }
        
        if setBonus() == "elite void magic" {
            mult += 0.025
        }
        
        if Equipment.worn[.neck]!.name == "Salve amulet (i)" {
            mult += 0.15
        } else if Equipment.worn[.neck]!.name == "Salve amulet (ei)" {
            mult += 0.2
        }
        
        return mult
    }
    
    static func strengthPrayer() -> Float {
        var mult: Float = 1
        
        for pray in Prayer.activated {
            mult *= 1 + (Float(pray.strength) / 100)
        }
        
        return mult
    }
    
    static func attackPrayer() -> Float {
        var mult: Float = 1
        
        for pray in Prayer.activated {
            mult *= 1 + (Float(pray.attack) / 100)
        }
        
        return mult
    }
    
    static func magicPrayer() -> Float {
        var mult: Float = 1
        
        for pray in Prayer.activated {
            mult *= 1 + (Float(pray.magic) / 100)
        }
        
        return mult
    }
    
    static func rangedPrayer() -> Float {
        var mult: Float = 1
        
        for pray in Prayer.activated {
            mult *= 1 + (Float(pray.ranged_damage) / 100)
        }
        
        return mult
    }
    
    static func rangedAttackPrayer() -> Float {
        var mult: Float = 1
        
        for pray in Prayer.activated {
            mult *= 1 + (Float(pray.ranged_attack) / 100)
        }
        
        return mult
    }
    
    static func strength() -> Float {
        var const: Float = 0
        switch CombatStyle.selected!.style {
        case .aggressive:
            const = 11
        case .controlled:
            const = 9
        default:
            const = 8
        }
        return floor(strengthPrayer() * Float(Stats.getBoosted("strength"))) + const
    }
    
    static func ranged() -> Float {
        var const: Float = 0
        switch CombatStyle.selected!.style {
        case .accurate:
            const = 11
        default:
            const = 8
        }
        return floor(rangedPrayer() * Float(Stats.getBoosted("ranging"))) + const
    }
    
    static func magic() -> Float {
        var dmg:Float = 0
        if Spell.selected != nil {
            dmg = Float(Spell.selected!.getDamage())
        } else {
            if Equipment.isActivated("Trident of the seas", .mainhand) {
                dmg = floor(Float(Stats.getBoosted("magic"))/3) - 5
            } else if Equipment.isActivated("Trident of the swamp", .mainhand) {
                dmg = floor(Float(Stats.getBoosted("magic"))/3) - 2
            } else if Weapon.equiped.name.range(of:" salamander") != nil || Weapon.equiped.name.range(of:" lizard") != nil {
                var s = 0
                
                switch Weapon.equiped.name {
                case "Black salamander":
                    s = 92
                case "Red salamander":
                    s = 77
                case "Orange salamander":
                    s = 59
                case "Swamp lizard":
                    s = 56
                default: ()
                }
                
                dmg = floor(0.5 + (Float(Stats.getBoosted("magic")) * Float(64 + s)/640))
            }
        }
        
        return dmg
    }
    
    static func maxRoll() -> Int {
        var att: Float = Float(attackBonus(CombatStyle.selected!.attack))
        let salve = Equipment.worn[.neck]!.name.range(of: "Salve ") != nil
        
        switch CombatStyle.selected!.type {
        case .melee:
            if salve {
                if Equipment.isActivated("Salve amulet", .neck) {
                    att *= 7/6
                } else {
                    att *= 1.2
                }
            } else if Opponent.onTask && (Equipment.isActivated("Slayer helmet", .head) || Equipment.isActivated("Slayer helmet (i)", .head) || Equipment.isActivated("Black mask", .head) || Equipment.isActivated("Black mask (i)", .head)) {
                att *= 7/6
            }
        case .ranged, .magic:
            if salve {
                if Equipment.isActivated("Salve amulet (i)", .neck) {
                    att *= 1.15
                } else if Equipment.isActivated("Salve amulet (ei)", .neck) {
                    att *= 1.2
                }
            } else if Opponent.onTask && (Equipment.isActivated("Slayer helmet (i)", .head) || Equipment.isActivated("Black mask (i)", .head)) {
                att *= 1.15
            }
        default:()
        }
        
        return attack() * Int(attackEffect()*floor(att)+64)
    }
    
    static func attack() -> Int {
        var lvl = 1
        var pray: Float = 1
        var const = 0
        var void: Float = 1
        
        let set = setBonus()
        
        switch CombatStyle.selected!.type {
        case .melee:
            lvl = Stats.getBoosted("attack")
            pray = attackPrayer()
            switch CombatStyle.selected!.style {
            case .accurate:
                const = 11
            case .controlled:
                const = 9
            default:
                const = 8
            }
            if set == "void melee" || set == "elite void melee" {
                void = 1.1
            }
        case .magic:
            lvl = Stats.getBoosted("magic")
            pray = magicPrayer()
            if Equipment.isActivated("Trident of the seas", .mainhand) || Equipment.isActivated("Trident of the swamp", .mainhand) {
                switch CombatStyle.selected!.style {
                case .accurate:
                    const = 11
                case .longrange:
                    const = 9
                default:
                    const = 8
                }
            }
            if set == "void mage" || set == "elite void mage" {
                void = 1.45
            }
        case .ranged:
            lvl = Stats.getBoosted("ranging")
            pray = rangedAttackPrayer()
            if CombatStyle.selected!.style == .accurate {
                const = 11
            } else {
                const = 8
            }
            if set == "void ranged" || set == "elite void ranged" {
                void = 1.1
            }
        default:
            const = 8
        }
        
        return Int(Float(Int(Float(lvl)*pray) + const) * void)
    }
    
    static func defenceRoll() -> Int {
        var stat = "defence"
        if CombatStyle.selected!.type == .magic {
            stat = "magic"
        }
        return Opponent.selected!.combatStats[stat]! * (Opponent.selected!.defensiveStats[CombatStyle.selected!.attack]!+64)
    }
    
    static func hitChance() -> Float {
        let att = Float(maxRoll())
        let def = Float(defenceRoll())
        
        if att > def {
            return 1 - (def + 2) / (2*(att+1))
        }
        
        var chance = att / (2*(def+1))
        
        if chance > 1 {
            chance = 1
        }

        return chance
        
        //TODO bolts (e) keris, gadderhammer, verac procs
    }
    
    static func averageHit(_ upTo: Int) -> Float {
        var hit = 0
        
        for i in 1...upTo {
            hit += i
        }
        
        return Float(hit) / Float(upTo)
    }
}
