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
    
    private let eventId: String
    private let isLocal: Bool
    
    private let eventSource: LDSwiftEventSource.EventSource
    private let handler: ConfigEventStore = ConfigEventStore()
    
    init(event: EventListing) {
        self.eventId = event.id
        self.isLocal = event.isLocal
        
        // Do this correctly with URL Components
        let urlString = "https://usacscoring-v7.firebaseio.com/events/\(event.id)/config.json"
        let url = URL(string: urlString)!
        
        let config = EventSource.Config(handler: self.handler, url: url)
        self.eventSource = EventSource(config: config)
        
        self.cancellable = self.handler.configPublisher.sink { [weak self] config in
            self?.config = config
        }
    }
    
    func fetchResults() {
        if isLocal {
            guard
                let localFile = Bundle.main.path(forResource: "\(eventId)-config", ofType: "json"),
                let json = try? String(contentsOfFile: localFile, encoding: .utf8)
            else {
                self.eventSource.start()
                return
            }
            
            let messageEvent = MessageEvent(data: json)
            self.handler.onMessage(eventType: "put", messageEvent: messageEvent)
        } else {
            self.eventSource.start()
        }
    }
    
    func writeToFile() {
        self.handler.writeMessagesToFile()
    }
}
