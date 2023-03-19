//
//  Competitor.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/18/23.
//

import Foundation

struct Competitor: Codable, Identifiable, Equatable {
    enum CodingKeys: String, CodingKey {
        case id = "memberId"
        case region
        case team
        case category
        case bib
        case name
        case scratch
    }
    
    var id: String
    
    let region: Region
    let team: String
    let category: Category
    let bib: Int?
    let name: String
    let scratch: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.region = try container.decode(Region.self, forKey: .region)
        self.team = try container.decode(String.self, forKey: .team)
        self.category = try container.decode(Category.self, forKey: .category)
        self.bib = try? container.decode(Int.self, forKey: .bib)
        self.name = try container.decode(String.self, forKey: .name)
        
        self.scratch = (try? container.decode(Bool.self, forKey: .scratch)) ?? false
        
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
