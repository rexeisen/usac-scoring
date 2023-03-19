//
//  EventRosterViewModel.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/18/23.
//

import Foundation
import Combine
import LDSwiftEventSource

class EventRosterViewModel: ObservableObject {
    @Published var roster: [Category : [Competitor]] = [:]
    private var cancellable: AnyCancellable? = nil
    
    private let eventSource: LDSwiftEventSource.EventSource
    private let handler: RosterEventStore = RosterEventStore()
    
    init(event: EventListing) {
        // Do this correctly with URL Components
        let urlString = "https://usacscoring-v7.firebaseio.com/events/\(event.id)/roster.json?print=pretty"
        let url = URL(string: urlString)!
        
        let config = EventSource.Config(handler: self.handler, url: url)
        self.eventSource = EventSource(config: config)
        
        self.cancellable = self.handler.rosterPublisher.sink { [weak self] roster in
            self?.roster = roster
        }
    }
    
    func fetchResults() {
        self.eventSource.start()
    }
}
