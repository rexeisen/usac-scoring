//
//  RouteCard.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/14/23.
//

import Foundation

struct RouteCardResponse: Codable {
    let data: RouteCardTopLevel
}

struct RouteCardTopLevel: Codable {
    let leadtr: RouteCardFinal
}

struct RouteCardFinal: Codable {
    let final: [String: [String : RouteCard]]
}

struct RouteCard: Codable, Hashable {
    private enum CodingKeys: String, CodingKey {
        case attempts
        case climberId = "mid"
        case routeId = "rid"
    }
    
    let attempts: [String]
    let climberId: String
    let routeId: String
    
    static func == (lhs: RouteCard, rhs: RouteCard) -> Bool {
        return lhs.climberId == rhs.climberId && lhs.routeId == rhs.routeId
    }
    
}
