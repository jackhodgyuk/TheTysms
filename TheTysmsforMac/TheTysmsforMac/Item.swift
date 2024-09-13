//
//  Item.swift
//  TheTysmsforMac
//
//  Created by Jack Hodgy on 28/08/2024.
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
