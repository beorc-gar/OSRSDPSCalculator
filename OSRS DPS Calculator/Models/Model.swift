//
//  Model.swift
//  OSRS DPS Calculator
//
//  Created by Bronson Graansma on 2018-03-15.
//  Copyright © 2018 Bronson Graansma. All rights reserved.
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
