//
//  EventResultViewModel.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/17/23.
//

import Foundation

class EventResultViewModel: ObservableObject {
    private let routeCardViewModel: RouteCardViewModel
    private let configurationViewModel: EventConfigViewModel
    
    init(event: EventListing) {
        self.routeCardViewModel = RouteCardViewModel(event: event)
        self.configurationViewModel = EventConfigViewModel(event: event)
    }
    
    func fetchResults() {
        self.routeCardViewModel.fetchResults()
        self.configurationViewModel.fetchResults()
    }
}
