//
//  UserType.swift
//  The Tysms
//
//  Created by Jack Hodgy on 22/08/2024.
//


import Foundation
import FirebaseFirestore

enum UserType: String, Codable {
    case admin
    case manager
    case bandMember
}

struct UserRole: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var email: String
    var role: UserType
}
