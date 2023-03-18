//
//  RouteCardViewModel.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/14/23.
//

import Foundation
import LDSwiftEventSource
import Combine

class RouteCardViewModel: ObservableObject {
    private var cancellable: AnyCancellable? = nil
    @Published var routeCards: [RouteCard] = []
    
    private let eventSource: LDSwiftEventSource.EventSource
    private let handler: RouteCardEventStore = RouteCardEventStore()
    
    init(event: EventListing) {
        // Do this correctly with URL Components
        let urlString = "https://usacscoring-v7.firebaseio.com/events/\(event.id)/routecard.json?print=pretty"
        let url = URL(string: urlString)!
        
        let config = EventSource.Config(handler: self.handler, url: url)
        self.eventSource = EventSource(config: config)
        
        self.cancellable = self.handler.routePublisher.sink { [weak self] routes in
            self?.routeCards.append(contentsOf: routes)
        }
    }
    
    func fetchResults() {
        self.eventSource.start()
    }
}
