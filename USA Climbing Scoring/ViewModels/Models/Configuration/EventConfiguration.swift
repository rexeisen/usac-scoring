//
//  EventConfiguration.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/17/23.
//

import Foundation

struct EventConfigurationContainer: Codable {
    let data: EventConfiguration
}

struct EventConfiguration: Identifiable, Codable {
    enum CodingKeys: String, CodingKey {
        case id = "eid"
        case categories
        case city
        case state
        case zip
        case timezone
        case routes
    }
    
    enum MaybeCodingKeys: String, CodingKey {
        case dateStart
        case dateEnd
    }
    
    var id: String
    
    // MARK: Competition Information
    let categories: [Category]
    // let format: String
    // let infoSheet: String
    // let level: String
    // let region: Region
    // let name: String
    
    // MARK: - Location Information
    let city: String
    let state: String
    let zip: String
    
    // MARK: - Timing Information
    let dateStart: Date?
    let dateEnd: Date?
    let timezone: String?
    
    let routes: [Category: [String]]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.categories = try container.decode([Category].self, forKey: .categories)
        self.city = try container.decode(String.self, forKey: .city)
        self.state = try container.decode(String.self, forKey: .state)
        self.zip = try container.decode(String.self, forKey: .zip)
        
        if let maybeContainer = try? decoder.container(keyedBy: MaybeCodingKeys.self),
            let dateStartString = try? maybeContainer.decode(String.self, forKey: .dateStart),
           let dateEndString = try? maybeContainer.decode(String.self, forKey: .dateEnd)
        {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = "yyyy/MM/dd"
            
            if let castStart = dateFormatter.date(from: dateStartString) {
                self.dateStart = castStart
            } else {
                self.dateStart = nil
            }
            
            if let castEnd = dateFormatter.date(from: dateEndString) {
                self.dateEnd = castEnd
            } else {
                self.dateEnd = nil
            }
        } else {
            self.dateStart = nil
            self.dateEnd = nil
        }
        
        
        if let timezone = try? container.decode(String.self, forKey: .timezone) {
            self.timezone = timezone
        } else {
            self.timezone = nil
        }
        
        let parsedRoute = try container.decode(_RouteType.self, forKey: .routes)
        self.routes = parsedRoute.leadtr.final.catRoutes
    }
    
    // Route Decoding structures
    private struct _RouteType: Codable {
        let leadtr: _RouteLeadTR
    }
    
    private struct _RouteLeadTR: Codable {
        let final: _RouteFinal
    }

    private struct _RouteFinal: Codable {
        let catRoutes: [Category: [String]]
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<EventConfiguration._RouteFinal.CodingKeys> = try decoder.container(keyedBy: EventConfiguration._RouteFinal.CodingKeys.self)
            
            
            // This could be string or ints. Thanks JavaScript!
            var proxyContainer: [String : [String]] = [:]
            
            if let stringlyTypedContainer = try? container.decode([String : [String]].self, forKey: EventConfiguration._RouteFinal.CodingKeys.catRoutes) {
                proxyContainer = stringlyTypedContainer
            } else if let intTypedContainer = try? container.decode([String : [Int]].self, forKey: EventConfiguration._RouteFinal.CodingKeys.catRoutes) {
                for (key, value) in intTypedContainer {
                    let converted = value.map({String($0)})
                    proxyContainer[key] = converted
                }
            }
            
            var converted: [Category : [String]] = [:]
            for (key, value) in proxyContainer {
                guard let category = Category(rawValue: key) else { continue }
                converted[category] = value
            }
            
            self.catRoutes = converted
        }
    }
}
