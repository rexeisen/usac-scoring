//
//  ConfigEventStore.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/17/23.
//

import Foundation
import LDSwiftEventSource
import Combine

class ConfigEventStore: EventHandler {
    lazy private(set) var configPublisher: AnyPublisher<EventConfiguration, Never> = {
        return _configPublisher.eraseToAnyPublisher()
    }()
    private let _configPublisher: PassthroughSubject<EventConfiguration, Never> = PassthroughSubject()
    
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
                let topLevel = try decoder.decode(EventConfigurationContainer.self, from: data)
                _configPublisher.send(topLevel.data)
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

