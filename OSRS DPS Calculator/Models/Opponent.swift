//
//  Opponent.swift
//  OSRS DPS Calculator
//

import Foundation

class Opponent: Model {
    var undead: Bool
    var type: OpponentType
    var level: Int
    var hitpoints: Int
    var slayerLevel: Int
    var combatStats: [String : Int]
    var defensiveStats: [AttackType : Int]
    
    static var selected : Opponent? = Opponent(id: -1, name: "Opponent...", type: .other, lvl: 1, hp: 1, slay: 1, combat: ["defence": 0, "magic": 0], defence: [.stab: 0, .crush: 0, .slash: 0, .magic: 0, .ranged: 0], undead: false)
    static var onTask: Bool = false
    static var validated: Bool = false
    
    init(id: Int, name: String, type: OpponentType, lvl: Int, hp: Int, slay: Int, combat: [String: Int], defence: [AttackType: Int], undead: Bool) {
        self.undead = undead
        self.type = type
        self.level = lvl
        self.hitpoints = hp
        self.slayerLevel = slay
        self.combatStats = combat
        self.defensiveStats = defence
        super.init(id, name)
    }
    
    override func activate() -> Bool {
        if canActivate() {
            let flag = Opponent.selected!.undead != undead
            Opponent.selected = self
            if flag {
                Spell.validate()
            }
            return true
        }
        return false
    }
    
    override class func validate() {
        if selected != nil && !selected!.canActivate() {
            selected?.deactivate()
            validated = true
        }
    }
    
    override func canActivate() -> Bool {
        return Stats.getBoosted("slayer") >= slayerLevel
    }
    
    class func filter(_ list: [Opponent]) -> [Opponent] {
        var filtered: [Opponent] = []
        
        for opponent in list {
            if opponent.canActivate() {
                filtered.append(opponent)
            }
        }
        
        return filtered
    }
    
    override class func initAll() -> [Model] {
        var opponents: [Opponent] = []
        
        if let path = Bundle.main.path(forResource: "opponents", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, [Dictionary<String, Any>]>, let opponentDatas = jsonResult["opponents"] {
                    
                    var i = 0
                    for opponentData in opponentDatas {
                        let n: String = opponentData["name"] as! String
                        let l: Int = opponentData["lvl"] as! Int
                        let h: Int = opponentData["hp"] as! Int
                        var c: [String : Int] = opponentData["stats"] as! [String:Int]
                        var d: [AttackType: Int] = [.stab: 0, .crush: 0, .slash: 0, .magic: 0, .ranged: 0]
                        var t: OpponentType = .other
                        var u: Bool = false
                        var s: Int = 1
                        
                        if c["magic"] == nil {
                            c["magic"] = 0
                        }
                        if c["defence"] == nil {
                            c["defence"] = 0
                        }
                        
                        let tempDef: [String : Int] = opponentData["def"] as! Dictionary<String, Int>
                        for tmp in tempDef {
                            d[AttackType.from(tmp.key)] = tmp.value
                        }
                        
                        if opponentData["type"] != nil {
                            t = OpponentType.from(opponentData["type"] as! String)
                        }
                        if opponentData["undead"] != nil {
                            u = true
                        }
                        if opponentData["slayer"] != nil {
                            s = opponentData["slayer"] as! Int
                        }
                        
                        opponents.append(Opponent(id: i, name: n, type: t, lvl: l, hp: h, slay: s, combat: c, defence: d, undead: u))
                        i += 1
                    }
                    
                }
            } catch {
                print(error)
            }
        }
        
        return opponents
    }
}

enum OpponentType {
    case demon
    case dragon
    case kalphite //also applies to scarabs
    case vampire
    case other
    case turoth //also applies to kurask
    case shade
    
    static func from(_ s: String) -> OpponentType {
        switch s.lowercased() {
        case "demon":
            return .demon
        case "dragon":
            return .dragon
        case "kalphite", "scarab":
            return .kalphite
        case "vampire":
            return .vampire
        case "turoth", "kurask":
            return .turoth
        case "shade":
            return .shade
        default:
            return .other
        }
    }
}
