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
    
    // What place the competitor is in
    var places: [Double : Int] = [:]
    
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
        
        // Right now we are going to just focus on scoring FYC.
        let roster = self.rosterViewModel.roster
        let routeCards = self.routeCardViewModel.routeCards
        
        // Get the roster for FYC
        guard let competitors = roster[.FYC] else {
            return
        }
        
        // Get the routeCards for those members
        let competitorIDs = competitors.map({ $0.id })
        let filteredRouteCards = routeCards.filter { card in
            competitorIDs.contains(card.climberId) && card.bestAttempt != nil
        }
        
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
            let sortedRouteCards = routeCards.sorted(by: >)
            
            var previousScoreSentinel: Double = -1.0
            // Contains the competitors getting the calculated
            var scoringCollection: [String] = []
            
            // Figure out where they started
            var tieStartIndex: Int = 1
                        
            for (index, routeCard) in sortedRouteCards.enumerated() {
                guard let bestAttempt = routeCard.bestAttempt else { continue }
                if previousScoreSentinel == -1.0 {
                    previousScoreSentinel = bestAttempt.value
                }
                
                if previousScoreSentinel != bestAttempt.value {
                    // Set all the previous scores
                    let allScores = Array(tieStartIndex..<index + 1)
                    if allScores.count != scoringCollection.count {
                        debugPrint("THERE IS A SERIOUS MISCOUNT PROBLEM HERE")
                    }
                    
                    let totalPlaces = allScores.reduce(0,+)
                    let score = Double(totalPlaces) / Double(allScores.count)
                    
                    // Update all the climbers
                    for climberId in scoringCollection {
                        guard var currentRanking = rankings.first(where: { $0.competitor.id == climberId} ) else {
                            debugPrint("UNABLE TO FIND THE CLIMBER")
                            continue
                        }
                        
                        currentRanking.place[route] = score
                        currentRanking.updateScore()
                        rankings.update(with: currentRanking)
                    }
                    
                    // Now all the climbers have their score. Reset the caches
                    previousScoreSentinel = bestAttempt.value
                    scoringCollection = [routeCard.climberId]
                    tieStartIndex = index + 1
                    
                } else {
                    // Add this competitor to the tie list
                    scoringCollection.append(routeCard.climberId)
                }
                
            }
            
            let allScores = Array(tieStartIndex..<sortedRouteCards.count + 1)
            if allScores.count != scoringCollection.count {
                debugPrint("THERE IS A SERIOUS MISCOUNT PROBLEM HERE")
            }
            
            let totalPlaces = allScores.reduce(0,+)
            let score = Double(totalPlaces) / Double(allScores.count)
            
            // Update all the climbers
            for climberId in scoringCollection {
                guard var currentRanking = rankings.first(where: { $0.competitor.id == climberId} ) else {
                    debugPrint("UNABLE TO FIND THE CLIMBER")
                    continue
                }
                
                currentRanking.place[route] = score
                currentRanking.updateScore()
                rankings.update(with: currentRanking)
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
}

struct Ranking: Hashable, Identifiable, Comparable {
    static func < (lhs: Ranking, rhs: Ranking) -> Bool { lhs.score < rhs.score }
    
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
    
}
