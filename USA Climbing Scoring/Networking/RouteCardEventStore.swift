//
//  RouteCardEventStore.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/14/23.
//

import Foundation
import LDSwiftEventSource
import Combine

class RouteCardEventStore: EventHandler {
    lazy private(set) var routePublisher: AnyPublisher<[RouteCard], Never> = {
        return _routePublisher.eraseToAnyPublisher()
    }()
    private let _routePublisher: PassthroughSubject<[RouteCard], Never> = PassthroughSubject()
    private var messages: [String] = []
    
    func onOpened() {
        debugPrint("onOpened")
    }
    
    func onClosed() {
        debugPrint("onClosed")
    }
    
    func onMessage(eventType: String, messageEvent: LDSwiftEventSource.MessageEvent) {
        if eventType == "put" {
            messages.append(messageEvent.data)
            // Could be the initial data set (need to test with live data)
            guard let data = messageEvent.data.data(using: .utf8) else { return }
            let decoder = JSONDecoder()
            do {
                let topLevel = try decoder.decode(RouteCardResponse.self, from: data)
                _routePublisher.send(topLevel.routeCards)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func onComment(comment: String) {
        debugPrint("Comment:  \(comment)")
    }
    
    func onError(error: Error) {
        debugPrint("Error: \(error)")
    }
    
    func writeMessagesToFile() {
        let routeCardsItem: String = "routeCardMessages.txt"
        let stringToWrite = messages.joined(separator: "\n:\n")
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let pathC: URL = documentsDirectory.appending(path: routeCardsItem)
        print("!!! WROTE TO \(pathC)")
        try? stringToWrite.write(to: pathC, atomically: true, encoding: .utf8)
    }
    
}

