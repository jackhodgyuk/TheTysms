//
//  Finance.swift
//  The Tysms
//
//  Created by Jack Hodgy on 23/08/2024.
//


import Foundation

struct Finance: Identifiable, Codable {
    var id: String?
    let date: Date
    let amount: Double
    let description: String
    let type: FinanceType
    let category: String
    
    enum FinanceType: String, Codable {
        case income
        case expense
    }
}
