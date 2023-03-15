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
    }
    
    let id: String
    let categories: [Category]
    let dateStart: Date
    let dateEnd: Date
    let name: String
}
