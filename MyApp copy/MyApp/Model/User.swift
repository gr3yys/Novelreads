//
//  User.swift
//  MyApp
//
//  Created by greys on 10/6/24.
//

import Foundation

struct User: Codable {
    var id: String
    var username: String
    var email: String
    var profileImageUrl: String?
    var bio: String?
}
