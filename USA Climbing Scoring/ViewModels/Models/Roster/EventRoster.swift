//
//  EventRoster.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/18/23.
//

import Foundation

struct EventRosterContainer: Codable {
    let data: [Category : [Competitor]]
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<EventRosterContainer.CodingKeys> = try decoder.container(keyedBy: EventRosterContainer.CodingKeys.self)
        
        let parsedRoute = try container.decode(_EventType.self, forKey: .data)
        var convertedData: [Category : [Competitor]] = [:]
        for (key, value) in parsedRoute.leadtr.final {
            guard let category = Category(rawValue: key) else {
                continue
            }
            var competitors: [Competitor] = []
            for (_, competitor) in value {
                competitors.append(competitor)
            }
            convertedData[category] = competitors
            
        }
        self.data = convertedData
    }
    
    // Route Decoding structures
    private struct _EventType: Codable {
        let leadtr: _EventLeadTR
    }
    
    private struct _EventLeadTR: Codable {
        let final: [String : [String : Competitor]]
    }
}

struct EventRoster: Codable {
}
