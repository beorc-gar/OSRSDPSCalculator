//
//  Prayer.swift
//  OSRS DPS Calculator
//
//  Created by Bronson Graansma on 2018-03-13.
//  Copyright © 2018 Bronson Graansma. All rights reserved.
//

import Foundation

class Prayer: Model {
    var attack: Int
    var strength: Int
    var ranged_attack: Int
    var ranged_damage: Int
    var magic: Int
    
    var level: Int
    var type: PrayerType
    
    static var activated: [Prayer] = []
    static var validated: Bool = false
    
    init(id: Int, name: String, type: PrayerType, level: Int, attack: Int, strength: Int, r_attack: Int, r_damage: Int, magic: Int) {
        self.type = type
        self.level = level
        self.attack = attack
        self.strength = strength
        self.ranged_attack = r_attack
        self.ranged_damage = r_damage
        self.magic = magic
        super.init(id, name)
    }
    
    override func activate() -> Bool {
        if !canActivate() {return false}
        
        for prayer in Prayer.activated {
            if !compatableWith(prayer) {
                prayer.deactivate()
            }
        }
        Prayer.activated.append(self)
        return true
    }
    
    override func isActivated() -> Bool {
        for p in Prayer.activated {
            if p.id == id {return true}
        }
        return false
    }
    
    override func compatableWith(_ other: Model) -> Bool {
        if let pray = other as? Prayer {
            return (self.type == .arm && pray.type == .brain) || (self.type == .brain && pray.type == .arm)
        } else {
            return false
        }
    }
    
    override func canActivate() -> Bool {
        return Stats.get("prayer") >= level
    }
    
    override func deactivate() {
        var i = 0
        for p in Prayer.activated {
            if p.id == id {
                Prayer.activated.remove(at: i)
                return
            }
            i += 1
        }
    }
    
    override class func validate() {
        for p in activated.reversed() {
            if !p.canActivate() {
                p.deactivate()
            }
        }
        validated = true
    }
    
    override class func initAll() -> [Model] {
        var prayers:[Prayer] = []
        
        if let path = Bundle.main.path(forResource: "prayers", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, [Dictionary<String, Any>]>, let prayerDatas = jsonResult["prayers"] {
                    
                    var i = 0
                    for prayerData in prayerDatas {
                        let n: String = prayerData["name"] as! String
                        let l: Int = prayerData["req"] as! Int
                        var t: PrayerType = .other
                        var a: Int = 0
                        var s: Int = 0
                        var ra: Int = 0
                        var rd: Int = 0
                        var m: Int = 0
                        
                        if prayerData["arm"] != nil {
                            t = .arm
                        } else if prayerData["brain"] != nil {
                            t = .brain
                        } else if prayerData["eye"] != nil {
                            t = .eye
                        } else if prayerData["pyramid"] != nil {
                            t = .pyramid
                        }
                        
                        if prayerData["attack"] != nil {
                            a = prayerData["attack"] as! Int
                        }
                        if prayerData["strength"] != nil {
                            s = prayerData["strength"] as! Int
                        }
                        if prayerData["magic"] != nil {
                            m = prayerData["magic"] as! Int
                        }
                        if prayerData["ranged_attack"] != nil {
                            ra = prayerData["ranged_attack"] as! Int
                        }
                        if prayerData["ranged_damage"] != nil {
                            rd = prayerData["ranged_damage"] as! Int
                        }
                        
                        prayers.append(Prayer(id: i, name: n, type: t, level: l, attack: a, strength: s, r_attack: ra, r_damage: rd, magic: m))
                        i += 1
                    }
                    
                }
            } catch {
                print(error)
            }
        }
        
        return prayers
    }
}

enum PrayerType {
    case brain
    case arm
    case eye
    case pyramid
    case other
}
