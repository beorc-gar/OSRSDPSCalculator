//
//  Inventory.swift
//  OSRS DPS Calculator
//

import Foundation

class Item: Model {
    
    var boosts: [Boost]
    
    static var activated: [Item] = []
    
    init(id: Int, name: String, boosts: [Boost]) {
        self.boosts = boosts
        super.init(id, name)
    }
    
    override func activate() -> Bool {
        for item in Item.activated {
            if !compatableWith(item) {
                item.deactivate()
            }
        }
        Item.activated.append(self)
        Item.applyBoosts()
        
        return true
    }
    
    override func deactivate() {
        var i = 0
        for item in Item.activated {
            if item.id == id {
                Item.activated.remove(at: i)
                break
            }
            i += 1
        }
        Item.applyBoosts()
    }
    
    override func isActivated() -> Bool {
        for item in Item.activated {
            if item.id == id {
                return true
            }
        }
        return false
    }
    
    override func compatableWith(_ other: Model) -> Bool {
        if (name == "magic_potion" && other.name == "imbued_heart") || (other.name == "magic_potion" && name == "imbued_heart") {return false}
        
        let parts = name.components(separatedBy: "_")
        var comparator = name
        for part in parts {
            if part != "potion" && part != "super" {
                comparator = part
                break
            }
        }
        return other.name.range(of: comparator) == nil && comparator.range(of: other.name) == nil
    }
    
    class func applyBoosts() {
        Stats.resetBoosts()
        for item in activated {
            for boost in item.boosts {
                boost.apply()
            }
        }
        Stats.validated = true
    }
    
    override class func validate() {
        applyBoosts()
    }
    
    override class func initAll() -> [Model] {
        var items: [Item] = []
        
        if let path = Bundle.main.path(forResource: "items", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, [Dictionary<String, Any>]>, let itemDatas = jsonResult["items"] {
                    
                    var i = 0
                    for itemData in itemDatas {
                        let n: String = itemData["name"] as! String
                        let b: [Boost] = Boost.initAll(itemData)
                        
                        items.append(Item(id: i, name: n, boosts: b))
                        i += 1
                    }
                }
            } catch {
                print(error)
            }
        }
        
        return items
    }
}

class Boost {
    var stat: String = ""
    var percent: Int = 0
    var flat: Int = 0
    var set: Int?
    
    func apply() {
        var lvl = Stats.get(stat)
        
        lvl += Int((Float(percent)/100.0) * Float(lvl))
        lvl += flat

        if Stats.getBoosted(stat) < lvl {
            Stats.setBoosted(stat, lvl)
        } else if set != nil {
            Stats.setBoosted(stat, set!)
        }
    }
    
    class func initAll(_ data: Dictionary<String, Any>) -> [Boost] {
        var boosts: [Boost] = []
        for key in data.keys {
            if key != "name" {
                let boost: Boost = Boost()
                boost.stat = key
                var b: Dictionary<String, Int> = data[key] as! Dictionary<String, Int>
                
                if b["flat"] != nil {
                    boost.flat = b["flat"]!
                }
                if b["percent"] != nil {
                    boost.percent = b["percent"]!
                }
                if b["set"] != nil {
                    boost.set = b["set"]!
                }
                boosts.append(boost)
            }
        }
        return boosts
    }
}
