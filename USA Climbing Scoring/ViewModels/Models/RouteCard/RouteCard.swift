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
    
    let attempts: [Attempt]
    let climberId: String
    let routeId: String
    
    var bestAttempt: Attempt? {
        return attempts.sorted(by: >).first
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        
        if let rawAttemptString = try? container.decode([String].self, forKey: .attempts) {
            var builtAttempts: [Attempt] = []
            for (index, element) in rawAttemptString.enumerated() {
                builtAttempts.append(Attempt(score: element, attempt: index + 1))
            }
            
            self.attempts = builtAttempts
        } else {
            self.attempts = []
        }
        self.climberId = try container.decode(String.self, forKey: .climberId)
        self.routeId = try container.decode(String.self, forKey: .routeId)
    }
    
    static func == (lhs: RouteCard, rhs: RouteCard) -> Bool {
        return lhs.climberId == rhs.climberId && lhs.routeId == rhs.routeId
    }
    
}

struct Attempt: Codable, Hashable, Comparable {
    static func < (lhs: Attempt, rhs: Attempt) -> Bool {
        return lhs.value < rhs.value
    }
    
    let value: Double
    let score: String
    let attempt: Int
    
    init(score: String, attempt: Int) {
        
        var localScore: Double = 0.0
        
        if score.lowercased() == "top" {
            localScore = 100
        } else if score.contains("+") {
            let strippedScore = score.replacingOccurrences(of: "+", with: "")
            let rawValue = Double(strippedScore) ?? 0.0
            localScore = rawValue + 0.5
        } else {
            localScore = Double(score) ?? 0.0
        }
        
        localScore -= (Double(attempt) * 0.001)
        
        self.value = localScore
        self.score = score
        self.attempt = attempt
    }
}
