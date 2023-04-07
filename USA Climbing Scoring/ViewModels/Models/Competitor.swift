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
    
    enum RoundKeys: String, CodingKey {
        case final
    }
    
    
    private enum EventCodingKeys: String, CodingKey {
        /*
         "advance" : 0,
         "npts" : "",
         "pts" : "",
         "rank" : "",
         "score" : "",
         "so" : [ null, 28, 42, 14 ],
         "st" : [ null, "09:48:00", "10:44:00", "08:52:00" ],
         "start" : "",
         "wave" : ""
         */
        case so
        case st
    }
    
    var id: String
    
    let region: Region
    let team: String
    let category: Category
    let bib: Int?
    let name: String
    let scratch: Bool
    // This is the routeId with the date
    let startTimes: [String : Date]
    var firstTime: Date? {
        return startTimes.values.sorted().first
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.region = try container.decode(Region.self, forKey: .region)
        self.team = try container.decode(String.self, forKey: .team)
        self.category = try container.decode(Category.self, forKey: .category)
        self.bib = try? container.decode(Int.self, forKey: .bib)
        self.name = try container.decode(String.self, forKey: .name)
        
        self.scratch = (try? container.decode(Bool.self, forKey: .scratch)) ?? false
        
        let roundContainer = try decoder.container(keyedBy: RoundKeys.self)
        
        if let finalContainer = try? roundContainer.nestedContainer(keyedBy: EventCodingKeys.self, forKey: .final), let so = try? finalContainer.decode([Int?].self, forKey: .so) {
            let st = try finalContainer.decode([String?].self, forKey: .st)
            
            guard so.count == st.count else {
                startTimes = [:]
                return
            }
            
            let zipped = zip(so, st)
            var mappedItems: [String : Date] = [:]

            
            for (routeId, startTime) in zipped {
                guard let routeId, let startTime else { continue }
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                dateFormatter.dateFormat = "HH:mm:ss"
                guard let formattedDate = dateFormatter.date(from: startTime) else {
                    continue
                }
                
                mappedItems[String(routeId)] = formattedDate
            }
            
            
            startTimes = mappedItems
        } else {
            startTimes = [:]
        }
        
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
