//
//  Models.swift
//  AlcoMark
//
//  Created by Aleksandr Khrebtov on 14.10.2024.
//


import Foundation
import SwiftData

@Model
final class DrinkCategory {
    var name: String
    @Relationship(deleteRule: .cascade) var items: [DrinkItem] = []
    
    init(name: String) {
        self.name = name
    }
}

@Model
final class DrinkItem {
    var exciseStampCode: String
    var volume: String
    var alcoName: String
  
    
    init(exciseStampCode: String, volume: String, alcoName: String) {
        self.exciseStampCode = exciseStampCode
        self.volume = volume
        self.alcoName = alcoName
    }
}
