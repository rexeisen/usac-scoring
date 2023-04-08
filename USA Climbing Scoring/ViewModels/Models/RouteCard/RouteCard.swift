//
//  RouteCard.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/14/23.
//

import Foundation

struct RouteCardResponse: Codable {
    private let data: RouteCardTopLevel?
    let path: String
    
    var routeCards: [RouteCard]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.path = try container.decode(String.self, forKey: .path)
        
        if path.count > 1 {
            // This is a patch
            self.data = nil
            let routeCard = try container.decode(RouteCard.self, forKey: .data)
            self.routeCards = [routeCard]
        } else {
            let routeData = try container.decode(RouteCardTopLevel.self, forKey: .data)
            self.data = routeData
            let routes = routeData.leadtr.final
            let routeCards = routes.values
                .flatMap { competitor in
                    return competitor.values
                }
            self.routeCards = routeCards
        }
        
    }
}

struct RouteCardTopLevel: Codable {
    let leadtr: RouteCardFinal
}

struct RouteCardFinal: Codable {
    let final: [String: [String : RouteCard]]
}

enum RouteCardValue: Hashable, Comparable {
    case bestAttempt(Double)
    case startTime(Date)
    
    static func < (lhs: RouteCardValue, rhs: RouteCardValue) -> Bool {
        switch (lhs, rhs) {
        case (.bestAttempt(let lhsValue), .bestAttempt(let rhsValue)):
            return lhsValue < rhsValue
        case (.bestAttempt(_), .startTime(_)):
            return false
            
        case (.startTime(_), .bestAttempt(_)):
            return true
        case (.startTime(let lhsStart), .startTime(let rhsStart)):
            return lhsStart < rhsStart
        }
    }
}

struct RouteCard: Codable, Hashable, Comparable {
    private enum CodingKeys: String, CodingKey {
        case attempts
        case climberId = "mid"
        case routeId = "rid"
    }
    
    let attempts: [Attempt]
    let climberId: String
    let routeId: String
    var startTime: Date?
    var value: RouteCardValue {
        if let bestAttempt = self.bestAttempt {
            return .bestAttempt(bestAttempt.value)
        } else if let startTime = self.startTime {
            return .startTime(startTime)
        } else {
            return .startTime(Date.distantFuture)
        }
    }
    
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
    
    // MARK: Protocol Conformance
    
    static func < (lhs: RouteCard, rhs: RouteCard) -> Bool {
        return lhs.value < rhs.value
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.climberId)
        hasher.combine(self.routeId)
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
