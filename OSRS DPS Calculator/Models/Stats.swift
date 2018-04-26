//
//  Stats.swift
//  OSRS DPS Calculator
//
//  Created by Bronson Graansma on 2018-03-11.
//  Copyright © 2018 Bronson Graansma. All rights reserved.
//

import Foundation

class Stats {
    private static var levels:[String: Level] = [
        "attack": Level(1),
        "strength": Level(1),
        "defence": Level(1),
        "magic": Level(1),
        "ranging": Level(1),
        "hitpoints": Level(10),
        "prayer": Level(1),
        "slayer": Level(1),
        "agility": Level(1)
    ]
    
    static var name: String = ""
    
    static let stats:[String] = [
        "attack",
        "strength",
        "defence",
        "magic",
        "ranging",
        "hitpoints",
        "prayer",
        "slayer",
        "agility"
    ]
    
    static var validated: Bool = false
    
    public class func levels(_ lvls: [Int]) {
        for i in 0...lvls.count-1 {
            levels[stats[i]] = Level(lvls[i])
        }
        
        notify()
    }
    
    public class func lookup(_ name: String, _ callback: @escaping (_ success: Bool)->Void) {
        let url = URL(string: "http://services.runescape.com/m=hiscore_oldschool/index_lite.ws?player="+(name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!))
        let task = URLSession.shared.dataTask(with: url!) {(info, response, error) in
            if error != nil {
                print(error!.localizedDescription)
                callback(false)
            } else if info != nil {
                let data = String(data: info!, encoding: .utf8)!.components(separatedBy: .newlines)
                var lvl: [Int] = []
                
                for line in data {
                    let vals = line.split(separator: ",")
                    if(vals.count == 3) {
                        lvl.append(Int(vals[1])!)
                    }
                }
                let success = lvl.count >= 20
                if success {
                    levels([lvl[1], lvl[3], lvl[2], lvl[7], lvl[5], lvl[4], lvl[6], lvl[19], lvl[17]])
                    self.name = name
                }
                callback(success)
            } else if response != nil {
                print(response!.description)
                callback(false)
            }
        }
        task.resume()
    }
    
    class func get(_ name: String) -> Int {
        return (levels[name]?.base)!
    }
    
    class func getBoosted(_ name: String) -> Int {
        return (levels[name]?.boosted)!
    }
    
    class func set(_ name: String, _ lvl: Int) {
        levels[name]?.base = lvl
        notify()
    }
    
    class func setBoosted(_ name: String, _ lvl: Int) {
        levels[name]?.boosted = lvl
        notifyBoost()
    }
    
    class func notify() {
        Item.validate()
        Prayer.validate()
        Spell.validate()
        Opponent.validate()
        Equipment.validate()
    }
    
    class func notifyBoost() {
        Spell.validate()
        Opponent.validate()
    }
    
    class func resetBoosts() {
        for stat in stats {
            levels[stat]?.boosted = (levels[stat]?.base)!
        }
        notifyBoost()
    }
}

class Level {
    var base: Int
    var boosted: Int
    
    init(_ lvl: Int) {
        base = lvl
        boosted = lvl
    }
}
