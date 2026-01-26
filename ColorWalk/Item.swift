//
//  Item.swift
//  ColorWalk
//
//  Created by 小妍寶 on 2026/1/22.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
