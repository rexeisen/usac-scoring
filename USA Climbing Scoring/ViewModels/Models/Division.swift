//
//  Division.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/14/23.
//

import Foundation

enum Division: String, Codable, CaseIterable {
    case division1 = "D1"
    case division2 = "D2"
    case division3 = "D3"
    case division4 = "D4"
    case division5 = "D5"
    case division6 = "D6"
    case division7 = "D7"
    case division8 = "D8"
    case division9 = "D9"
    
    init(region: Region) {
        switch region {
        case .region11, .region12:
            self = .division1
        case .region21, .region22:
            self = .division2
        case .region31, .region32:
            self = .division3
        case .region41, .region42:
            self = .division4
        case .region51, .region52:
            self = .division5
        case .region61, .region62:
            self = .division6
        case .region71, .region72:
            self = .division7
        case .region81, .region82:
            self = .division8
        case .region91, .region92:
            self = .division9
        }
    }
    
    var regions: [Region] {
        switch self {
        case .division1:
            return [.region11, .region12]
        case .division2:
            return [.region21, .region22]
        case .division3:
            return [.region31, .region32]
        case .division4:
            return [.region41, .region42]
        case .division5:
            return [.region51, .region52]
        case .division6:
            return [.region61, .region62]
        case .division7:
            return [.region71, .region72]
        case .division8:
            return [.region81, .region82]
        case .division9:
            return [.region91, .region92]
        }
    }
}
