//
//  Region.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/14/23.
//

import Foundation

// USAC Regions as defined at
// https://usaclimbing.org/compete/regions/
enum Region: String, Codable, CaseIterable {
    case region11 = "R11"
    case region12 = "R12"
    case region21 = "R21"
    case region22 = "R22"
    case region31 = "R31"
    case region32 = "R32"
    case region41 = "R41"
    case region42 = "R42"
    case region51 = "R51"
    case region52 = "R52"
    case region61 = "R61"
    case region62 = "R62"
    case region71 = "R71"
    case region72 = "R72"
    case region81 = "R81"
    case region82 = "R82"
    case region91 = "R91"
    case region92 = "R92"
    
    var division: Division {
        switch self {
            
        case .region11:
            return .division1
        case .region12:
            return .division1
        case .region21:
            return .division2
        case .region22:
            return .division2
        case .region31:
            return .division3
        case .region32:
            return .division3
        case .region41:
            return .division4
        case .region42:
            return .division4
        case .region51:
            return .division5
        case .region52:
            return .division5
        case .region61:
            return .division6
        case .region62:
            return .division6
        case .region71:
            return .division7
        case .region72:
            return .division7
        case .region81:
            return .division8
        case .region82:
            return .division8
        case .region91:
            return .division9
        case .region92:
            return .division9
        }
    }
}
