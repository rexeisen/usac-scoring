//
//  Category.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/14/23.
//

import Foundation

/// Youth Categories
enum Category: String, Codable, Hashable, CaseIterable {
    case FJR
    case FYA
    case FYB
    case FYC
    case FYD
    
    case MJR
    case MYA
    case MYB
    case MYC
    case MYD
}
