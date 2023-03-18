//
//  EventConfigViewModel.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/17/23.
//

import Foundation
import Combine
import LDSwiftEventSource

class EventConfigViewModel: ObservableObject {
    @Published var config: EventConfiguration? = nil
    private var cancellable: AnyCancellable? = nil
    
    private let eventSource: LDSwiftEventSource.EventSource
    private let handler: ConfigEventStore = ConfigEventStore()
    
    init(event: EventListing) {
        // Do this correctly with URL Components
        let urlString = "https://usacscoring-v7.firebaseio.com/events/\(event.id)/config.json?print=pretty"
        let url = URL(string: urlString)!
        
        let config = EventSource.Config(handler: self.handler, url: url)
        self.eventSource = EventSource(config: config)
        
        self.cancellable = self.handler.configPublisher.sink { [weak self] config in
            self?.config = config
        }
    }
    
    func fetchResults() {
        self.eventSource.start()
    }
}
