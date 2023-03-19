//
//  RosterEventStore.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/18/23.
//

import Foundation
import Combine
import LDSwiftEventSource

class RosterEventStore: EventHandler {
    lazy private(set) var rosterPublisher: AnyPublisher<[Category : [Competitor]], Never> = {
        return _rosterPublisher.eraseToAnyPublisher()
    }()
    private let _rosterPublisher: PassthroughSubject<[Category : [Competitor]], Never> = PassthroughSubject()
    
    func onOpened() {
        debugPrint("onOpened")
    }
    
    func onClosed() {
        debugPrint("onClosed")
    }
    
    func onMessage(eventType: String, messageEvent: LDSwiftEventSource.MessageEvent) {
        if eventType == "put" {
            // Could be the initial data set (need to test with live data)
            guard let data = messageEvent.data.data(using: .utf8) else { return }
            let decoder = JSONDecoder()
            do {
                let topLevel = try decoder.decode(EventRosterContainer.self, from: data)
                _rosterPublisher.send(topLevel.data)
            } catch {
                print(error)
            }
        }
    }
    
    func onComment(comment: String) {
        debugPrint("Comment:  \(comment)")
    }
    
    func onError(error: Error) {
        debugPrint("Error: \(error)")
    }
    
}

