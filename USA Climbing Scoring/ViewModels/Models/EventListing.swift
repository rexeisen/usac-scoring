//
//  EventListing.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/14/23.
//

import Foundation

struct EventListing: Hashable, Identifiable, Codable {
    private enum CodingKeys: String, CodingKey {
        case id = "eid"
        case categories
        case dateStart
        case dateEnd
        case name
        case isLocal
    }
    
    let id: String
    let categories: [Category]
    let dateStart: Date
    let dateEnd: Date
    let name: String
    let isLocal: Bool
    
    init(id: String, categories: [Category], dateStart: Date, dateEnd: Date, name: String, isLocal: Bool = false) {
        self.id = id
        self.categories = categories
        self.dateStart = dateStart
        self.dateEnd = dateEnd
        self.name = name
        self.isLocal = isLocal
    }
}
