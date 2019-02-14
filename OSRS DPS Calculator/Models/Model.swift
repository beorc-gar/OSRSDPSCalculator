//
//  Model.swift
//  OSRS DPS Calculator
//

import Foundation

class Model {
    var id: Int
    var name: String
    
    init(_ id: Int, _ name: String) {
        self.id = id
        self.name = name
    }
    
    func activate() -> Bool {
        return false
    }
    
    func deactivate() {
        
    }
    
    func isActivated() -> Bool {
        return false
    }
    
    func compatableWith(_ other: Model) -> Bool {
        return true
    }
    
    func canActivate() -> Bool {
        return true
    }
    
    class func validate() {
    }
    
    class func initAll() -> [Model] {
        return []
    }
}
