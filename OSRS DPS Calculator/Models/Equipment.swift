//
//  Equipment.swift
//  OSRS DPS Calculator
//
//  Created by Bronson Graansma on 2018-03-18.
//  Copyright © 2018 Bronson Graansma. All rights reserved.
//

import Foundation

class Equipment: Model {
    var slot: Slot
    var reqStats: [String: Int]
    var component_ids: [Int]
    var value: Int
    
    var stats: [AttackType:Int]
    var strength: Int
    var rangedStrength: Int
    var magicDamage: Int // this is percent
    
    var totalValue: Int = 0
    
    var setEffect: String?
    
    static let empty: [Slot:Equipment] = {
        var w: [Slot:Equipment] = [:]
        
        for s in Slot.initAll() {
            w[s] = Equipment(id: -1, name: "Empty", req: [:], stats:[
                .stab: 0,
                .slash: 0,
                .crush: 0,
                .magic: 0,
                .ranged: 0
                ], str: 0, rangedStrength: 0, magicDamage: 0, slot: s, trade: [], val: 0)
        }
        w[.mainhand] = Weapon.unarmed
        return w
    }()
    
    static var worn: [Slot:Equipment] = empty
    
    static var validated: Bool = false
    static var validatedSlot: [Slot] = []
    static var callback: ()->Void = {}
    
    //TODO bolt effects
    
    init(id: Int, name: String, req: [String: Int], stats: [AttackType:Int], str: Int, rangedStrength: Int, magicDamage: Int, slot: Slot, trade: [Int], val: Int) {
        self.slot = slot
        self.reqStats = req
        self.stats = stats
        self.strength = str
        self.rangedStrength = rangedStrength
        self.magicDamage = magicDamage
        self.component_ids = trade
        self.value = val
        super.init(id, name)
    }
    
    convenience init(id: Int, name: String, req: [String: Int], stats: [AttackType:Int], str: Int, rangedStrength: Int, magicDamage: Int, slot: Slot, trade: [Int], val: Int, set: String?) {
        self.init(id: id, name: name, req: req, stats: stats, str: str, rangedStrength: rangedStrength, magicDamage: magicDamage, slot: slot, trade: trade, val: val)
        setEffect = set
    }
    
    private func lookup(_ itemId: Int, _ group: DispatchGroup) {
        group.enter()
        let url = URL(string: "http://services.runescape.com/m=itemdb_oldschool/api/graph/"+String(itemId)+".json")
        let task = URLSession.shared.dataTask(with: url!) {(info, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else if info != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: info!, options: .mutableLeaves)
                    if let json = json as? Dictionary<String, Any> {
                        if json["daily"] != nil {
                            let daily = json["daily"] as! [String:Int]
                            var timestamps: [Int] = []
                            
                            for d in daily {
                                timestamps.append(Int(d.key)!)
                            }
                            
                            self.totalValue += daily[String(timestamps.max()!)]!
                        }
                    }
                } catch {
                    print(error)
                }
            } else if response != nil {
                print(response!.description)
            }
            group.leave()
        }
        task.resume()
    }
    
    private func appraise() {
        totalValue = value
        let group = DispatchGroup()
        
        for i in component_ids {
            lookup(i, group)
        }
        group.notify(queue: .main) {
            Equipment.callback()
        }
    }
    
    class func evaluate() -> Int {
        var val = 0
        for s in Slot.initAll() {
            let w = worn[s]!
            val += w.totalValue
        }
        return val
    }
    
    override func activate() -> Bool {
        if !canActivate() {
            return false
        }
        for s in Slot.initAll() {
            if Equipment.worn.keys.contains(s) {
                if !compatableWith(Equipment.worn[s]!) {
                    Equipment.worn[s]!.deactivate()
                }
            }
        }
        Equipment.worn[slot] = self
        if slot == .mainhand {
            CombatStyle.validate()
        }
        if totalValue == 0 {
            appraise()
        }
        return true
    }
    
    override func deactivate() {
        if isActivated() {
            Equipment.worn[slot] = Equipment.empty[slot]
            if slot == .mainhand {
                Equipment.worn[slot] = Weapon.unarmed
                CombatStyle.validate()
            }
        }
    }
    
    override func isActivated() -> Bool {
        if !Equipment.worn.keys.contains(slot) {
            return false
        }
        return Equipment.worn[slot]!.id == id
    }
    
    class func isActivated(_ name: String, _ slot: Slot) -> Bool {
        return worn.keys.contains(slot) && worn[slot]!.name == name
    }
    
    override func compatableWith(_ other: Model) -> Bool {
        let e = other as! Equipment
        
        if e.slot == .mainhand {
            let w = e as! Weapon
            return w.compatableWith(self)
        }
        return slot != e.slot
    }
    
    override func canActivate() -> Bool {        for req in reqStats {
            if Stats.get(req.key) < req.value {
                return false
            }
        }
        return true
    }
    
    override class func validate() {
        for s in Slot.initAll() {
            if worn.keys.contains(s) {
                if !worn[s]!.canActivate() {
                    worn[s]!.deactivate()
                    validated = true
                    validatedSlot.append(s)
                }
            }
        }
    }
    
    class func initAll() -> [Slot: [Equipment]] {
        var all:[Slot: [Equipment]] = [:]
        for s in Slot.initAll() {
            all[s] = [empty[s]!]
        }
        
        if let path = Bundle.main.path(forResource: "equipment", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, [Dictionary<String, Any>]> {
                    var i = 0
                    
                    for key in jsonResult.keys {
                        let equipDatas = jsonResult[key]!
                        var sub: [Equipment] = []
                        let s = Slot.from(key)!
                        
                        for equipData in equipDatas {
                            var ids:[Int] = []
                            let n = equipData["name"] as! String
                            var req: [String:Int] = [:]
                            var str = 0
                            var rSt = 0
                            var val = 0
                            var mDm = 0
                            let set: String? = equipData["set"] as? String
                            var sts: [AttackType:Int] = [
                                .stab: 0,
                                .slash: 0,
                                .crush: 0,
                                .magic: 0,
                                .ranged: 0
                            ]
                            
                            if equipData["id"] != nil {
                                ids = equipData["id"] as! [Int]
                            }
                            if equipData["value"] != nil {
                                val = equipData["value"] as! Int
                            }
                            if equipData["req"] != nil {
                                req = equipData["req"] as! [String:Int]
                            }
                            if equipData["strength"] != nil {
                                str = equipData["strength"] as! Int
                            }
                            if equipData["rangedStrength"] != nil {
                                rSt = equipData["rangedStrength"] as! Int
                            }
                            if equipData["magicDamage"] != nil {
                                mDm = equipData["magicDamage"] as! Int
                            }
                            if equipData["stats"] != nil {
                                let tmp = equipData["stats"] as! [String:Int]
                                for t in tmp {
                                    sts[AttackType.from(t.key)] = t.value
                                }
                            }
                            
                            if s == .mainhand {
                                let th = equipData["2h"] != nil
                                let spd = (equipData["speed"] as! NSNumber).floatValue
                                let tmp = equipData["attacks"] as! [[String:String]]
                                var atk: [CombatStyle] = []
                                
                                for t in tmp {
                                    atk.append(CombatStyle(name: t["name"]!, type: CombatType.from(t["type"]!), style: AttackStyle.from(t["style"]!)!, attack: AttackType.from(t["attack"]!)))
                                }
                                sub.append(Weapon(id: i, name: n, req: req, stats: sts, str: str, rangedStrength: rSt, magicDamage: mDm, trade: ids, val: val, twoHand: th, speed: spd, attacks: atk, set: set))
                                
                            } else {
                                sub.append(Equipment(id: i, name: n, req: req, stats:sts, str: str, rangedStrength: rSt, magicDamage: mDm, slot: s, trade: ids, val: val, set: set))
                            }
                            i += 1
                        }
                        all[s]?.append(contentsOf: sub)
                    }
                }
            } catch {
                print(error)
            }
        }
        
        return all
    }
    
}

class Weapon: Equipment {
    var twoHanded: Bool
    var speed: Float
    var attacks: [CombatStyle]
    
    static var equiped: Weapon {
        get {
            return Equipment.worn[.mainhand]! as! Weapon
        }
    }
    
    static var unarmed: Weapon = Weapon(id: -1, name: "Unarmed", req: [:], stats:[
        .stab: 0,
        .slash: 0,
        .crush: 0,
        .magic: 0,
        .ranged: 0
        ], str: 0, rangedStrength: 0, magicDamage: 0, trade: [], val: 0, twoHand: false, speed: 2.4, attacks: [
            CombatStyle(name: "Punch", type: .melee, style: .accurate, attack: .crush),
            CombatStyle(name: "Kick", type: .melee, style: .aggressive, attack: .crush),
            CombatStyle(name: "Block", type: .melee, style: .defensive, attack: .crush)
        ])
    
    //TODO special attack
    
    init(id: Int, name: String, req: [String:Int], stats: [AttackType: Int], str: Int, rangedStrength: Int, magicDamage: Int, trade: [Int], val: Int, twoHand: Bool, speed: Float, attacks: [CombatStyle]) {
        self.twoHanded = twoHand
        self.speed = speed
        self.attacks = attacks
        super.init(id: id, name: name, req: req, stats: stats, str: str, rangedStrength: rangedStrength, magicDamage: magicDamage, slot: .mainhand, trade: trade, val: val)
        self.attacks.append(CombatStyle(name: "Spell", type: .magic, style: .normal, attack: .magic))
    }
    
    convenience init(id: Int, name: String, req: [String:Int], stats: [AttackType: Int], str: Int, rangedStrength: Int, magicDamage: Int, trade: [Int], val: Int, twoHand: Bool, speed: Float, attacks: [CombatStyle], set: String?) {
        self.init(id: id, name: name, req: req, stats: stats, str: str, rangedStrength: rangedStrength, magicDamage: magicDamage, trade: trade, val: val, twoHand: twoHand, speed: speed, attacks: attacks)
        setEffect = set
    }
    
    override func compatableWith(_ other: Model) -> Bool {
        let e = other as! Equipment
        if e.slot == .mainhand || (twoHanded && e.slot == .offhand) {
            return false
        }
        return true
    }
}

enum Slot {
    case head
    case back
    case neck
    case quiver
    case mainhand
    case torso
    case offhand
    case legs
    case hands
    case feet
    case finger
    
    static func initAll() -> [Slot] {
        return [.head, .back, .neck, .quiver, .mainhand, .torso, .offhand, .legs, .hands, .feet, .finger]
    }
    
    static func from(_ s: String) -> Slot? {
        switch s.lowercased() {
        case "head":
            return .head
        case "back":
            return .back
        case "neck":
            return .neck
        case "quiver":
            return .quiver
        case "mainhand":
            return .mainhand
        case "torso":
            return .torso
        case "offhand":
            return .offhand
        case "legs":
            return .legs
        case "hands":
            return .hands
        case "feet":
            return .feet
        case "finger":
            return .finger
        default:
            return nil
        }
    }
}
