//
//  EventResultViewModel.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/17/23.
//

import Foundation
import Combine

class EventResultViewModel: ObservableObject {
    // The raw rankings
    @Published var rankings: [Ranking] = []
    @Published var currentCategory: Category = .FJR {
        didSet {
            self.calculateScores()
        }
    }
    @Published var categories: [Category] = []
    
    // What place the competitor is in.
    // Double is the competitor score, Int is the place
    var places: [Double : Int] = [:]
    var routes: [String] = []
    
    private let routeCardViewModel: RouteCardViewModel
    private let configurationViewModel: EventConfigViewModel
    private let rosterViewModel: EventRosterViewModel
    
    private var cancellable: AnyCancellable? = nil
    
    init(event: EventListing) {
        self.routeCardViewModel = RouteCardViewModel(event: event)
        self.configurationViewModel = EventConfigViewModel(event: event)
        self.rosterViewModel = EventRosterViewModel(event: event)
    }
    
    func fetchResults() {
        if cancellable == nil {
            self.cancellable = Publishers.CombineLatest3(self.configurationViewModel.$config,
                                                         self.rosterViewModel.$roster,
                                                         self.routeCardViewModel.$routeCards)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { config, roster, routeCards in
                if let config, self.categories.isEmpty, !config.categories.isEmpty {
                    self.categories = config.categories
                }
                
                if config != nil, roster.isEmpty == false, routeCards.count > 0 {
                    self.calculateScores()
                }
            })
        }
        
        self.routeCardViewModel.fetchResults()
        self.configurationViewModel.fetchResults()
        self.rosterViewModel.fetchResults()
    }
    
    func calculateScores() {
        guard
            let config = self.configurationViewModel.config,
            self.rosterViewModel.roster.isEmpty == false,
            self.routeCardViewModel.routeCards.isEmpty == false
        else {
            return
        }
        
        let roster = self.rosterViewModel.roster
        let routeCards = self.routeCardViewModel.routeCards
        
        // Get the roster for the current selected item
        guard let competitors = roster[self.currentCategory] else {
            return
        }
        
        var allRouteCards: Set<RouteCard> = []
        self.routes = []
        if let routesPerCategory = config.routes[self.currentCategory] {
            for competitorRoute in routesPerCategory {
                let routeName = "R\(competitorRoute)"
                self.routes.append(routeName)
                for competitor in competitors {
                    let blankCard = RouteCard(climberId: competitor.id, routeId: routeName)
                    allRouteCards.insert(blankCard)
                }
            }
        }
        
        for routeCard in routeCards {
            allRouteCards.update(with: routeCard)
        }
        
        // Get the routeCards for those members
        let competitorIDs = competitors.map({ $0.id })
        var filteredRouteCards = allRouteCards.filter { card in
            return competitorIDs.contains(card.climberId)
        }
                
        // For the route cards, we need to set all the start times
        var completedRoutedCards: Set<RouteCard> = []
        for filteredRouteCard in filteredRouteCards {
            var mutatedCard = filteredRouteCard
            guard let foundClimber = competitors.first(where: {$0.id == filteredRouteCard.climberId}) else {
                print("UNABLE TO FIND CLIMBER")
                continue
            }
            
            if let indexOfClimb = self.routes.firstIndex(of: filteredRouteCard.routeId),
               indexOfClimb < foundClimber.startTimes.count {
                let startTime = foundClimber.startTimes[indexOfClimb]
                mutatedCard.startTime = startTime
            } else {
                print("NO START TIME")
            }
            completedRoutedCards.insert(mutatedCard)
        }
        filteredRouteCards = completedRoutedCards
        
        // Setup the initial set of Rankings to be modified later
        var rankings: Set<Ranking> = []
        for competitor in competitors {
            let ranking = Ranking(competition: config.id,
                                  competitor: competitor,
                                  routeCards: filteredRouteCards.filter({$0.climberId == competitor.id}),
                                  place: [:])
            rankings.insert(ranking)
        }
        
        // Group the route cards by route
        let grouped = Dictionary(grouping: filteredRouteCards) { $0.routeId }
        
        // Sort the route cards by value
        for (route, routeCards) in grouped {
            let binned: [RouteCardValue : [RouteCard]] = Dictionary(grouping: routeCards) { $0.value }
            let binSortOrder = binned.keys.sorted(by: >)
            
            var tieStartIndex: Int = 1
            for order in binSortOrder {
                guard let cards = binned[order] else {
                    fatalError("Could not find this card.")
                }
                let allScores = Array(tieStartIndex..<tieStartIndex + cards.count)
                let totalPlaces = allScores.reduce(0,+)
                let score = Double(totalPlaces) / Double(allScores.count)
                
                // Update all the climbers
                for routeCard in cards {
                    guard var currentRanking = rankings.first(where: { $0.competitor.id == routeCard.climberId} ) else {
                        fatalError("UNABLE TO FIND THE CLIMBER")
                        continue
                    }
                    
                    currentRanking.place[route] = score
                    currentRanking.updateScore()
                    rankings.update(with: currentRanking)
                }
                tieStartIndex = tieStartIndex + cards.count
            }
        }

        let sortedRankings = rankings.sorted()
        
        // Gotta hit the overall placement now
        let groupings = Dictionary(grouping: sortedRankings, by: {$0.score})
        var totalCompetitorCount: Int = 1
        var places: [Double : Int] = [:]
        let sortedUniqueScores = groupings.keys.sorted()
        for score in sortedUniqueScores {
            let binnedScoreCount = (groupings[score] ?? []).count
            places[score] = totalCompetitorCount
            totalCompetitorCount += binnedScoreCount
        }

        self.places = places
        self.rankings = sortedRankings
    }
    
    func writeMessages() {
        self.routeCardViewModel.writeToFile()
        self.configurationViewModel.writeToFile()
        self.rosterViewModel.writeToFile()
    }
}

struct Ranking: Hashable, Identifiable, Comparable, CustomStringConvertible {
    var description: String {
        if !self.hasMadeAnAttempt() {
            if let firstDate = competitor.firstTime {
                return firstDate.formatted(date: .omitted, time: .shortened)
            } else {
                return "error"
            }
        } else {
            return score.formatted(.number.precision(.fractionLength(2)))
        }
    }
    
    static func < (lhs: Ranking, rhs: Ranking) -> Bool {
        switch (lhs.hasMadeAnAttempt(), rhs.hasMadeAnAttempt()) {
        case (true, true):
            return lhs.score < rhs.score
        case (true, false):
            return true
        case (false, true):
            return false
        case (false, false):
            guard let lhsFirst = lhs.competitor.firstTime, let rhsFirst = rhs.competitor.firstTime else {
                return true
            }
            return lhsFirst < rhsFirst
        }
    }
    
    var id: String { competition + "-" + competitor.id }
    var competition: String
    let competitor: Competitor
    let routeCards: [RouteCard]
    var place: [String : Double]
    var score: Double = 10000.0
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    mutating func updateScore() {
        let values: [Double] = place.values.map({$0})
        let allValues = Double(values.reduce(1, *))
        self.score = pow(allValues, 1.0 / Double(values.count))
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hasMadeAnAttempt() -> Bool {
        for routeCard in routeCards {
            if !routeCard.attempts.isEmpty {
                return true
            }
        }
        
        return false
    }
}
