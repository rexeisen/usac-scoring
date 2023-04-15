//
//  EventListingViewModel.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/14/23.
//

import Foundation

class EventListingViewModel: ObservableObject {
    @Published var currentEvents: [EventListing]
    
    init() {
        // Temporary
        self.currentEvents = [
            EventListing(id: "1209",
                         categories: Category.allCases,
                         dateStart: Date(),
                         dateEnd: Date(),
                         name: "QE R61 Vertical Endeavors Minneapolis"),
            EventListing(id: "1131",
                         categories: Category.allCases,
                         dateStart: Date(),
                         dateEnd: Date(),
                         name: "QE R41 Eagle Climbing"),
            EventListing(id: "1193",
                         categories: Category.allCases,
                         dateStart: Date(),
                         dateEnd: Date(),
                         name: "QE R61 Adventure Rock Milwaukee"),
            EventListing(id: "1196",
                         categories: Category.allCases,
                         dateStart: Date(),
                         dateEnd: Date(),
                         name: "QE R92 CRG Randolph",
                         isLocal: true),
            EventListing(id: "1188",
                         categories: Category.allCases,
                         dateStart: Date(),
                         dateEnd: Date(),
                         name: "QE R61 Frontier Climbing and Fitness",
                         isLocal: true)
        ]
    }
}
