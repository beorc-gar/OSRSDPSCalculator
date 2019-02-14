//
//  CombatStyle.swift
//  OSRS DPS Calculator
//

import Foundation

class CombatStyle: Model {
    var type: CombatType
    var style: AttackStyle
    var attack: AttackType
    
    static var selected: CombatStyle? = Weapon.equiped.attacks[0]
    static var validated: Bool = false
    
    init(name: String, type: CombatType, style: AttackStyle, attack: AttackType) {
        self.type = type
        self.style = style
        self.attack = attack
        super.init(0, name)
    }
    
    func equals(_ other: CombatStyle) -> Bool {
        return type == other.type && style == other.style && attack == other.attack
    }
    
    override func activate() -> Bool {
        CombatStyle.selected = self
        return true
    }
    
    override func deactivate() {
        if isActivated() && !canActivate() {
            for c in CombatStyle.initAll() {
                let cs = c as! CombatStyle
                if cs.attack == CombatStyle.selected?.attack {
                    CombatStyle.selected = cs
                    return
                }
            }
            CombatStyle.selected = CombatStyle.initAll()[0] as? CombatStyle
        }
    }
    
    override func isActivated() -> Bool {
        return equals(CombatStyle.selected!)
    }
    
    override func compatableWith(_ other: Model) -> Bool {
        return false
    }
    
    override func canActivate() -> Bool {
        for c in CombatStyle.initAll() {
            let cs = c as! CombatStyle
            if equals(cs) {
                return true
            }
        }
        return false
    }
    
    override class func validate() {
        selected!.deactivate()
        validated = true
    }
    
    override class func initAll() -> [Model] {
        return Weapon.equiped.attacks
    }
}

enum CombatType {
    case melee
    case ranged
    case magic
    case typeless
    
    static func from(_ s: String) -> CombatType {
        switch s.lowercased() {
        case "melee":
            return .melee
        case "magic":
            return .magic
        case "ranged":
            return .ranged
        default:
            return .typeless
        }
    }
}

enum AttackStyle {
    case accurate   // melee, ranged
    case aggressive // melee
    case defensive  // melee, magic
    case controlled // melee
    case rapid      // ranged
    case longrange  // ranged
    case normal     // magic
    
    static func from(_ s: String) -> AttackStyle? {
        switch s.lowercased() {
        case "accurate":
        return .accurate
        case "aggressive":
            return .aggressive
        case "defensive":
            return .defensive
        case "controlled":
            return .controlled
        case "rapid":
            return .rapid
        case "longrange":
            return .longrange
        case "normal":
            return .normal
        default:
            return nil
        }
    }
}

enum AttackType {
    case stab
    case slash
    case crush
    case magic
    case ranged
    case typeless
    
    static func initAll() -> [AttackType] {
        return [.stab, .slash, .crush, .magic, .ranged]
    }
    
    static func from(_ s: String) -> AttackType {
        switch s.lowercased() {
        case "stab":
            return .stab
        case "slash":
            return .slash
        case "crush":
            return .crush
        case "magic":
            return .magic
        case "ranged":
            return .ranged
        default:
            return .typeless
        }
    }
}
