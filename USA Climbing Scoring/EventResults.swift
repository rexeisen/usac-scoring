//
//  EventResults.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/14/23.
//

import SwiftUI

struct EventResults: View {
    var event: EventListing
    @ObservedObject var viewModel: EventResultViewModel
    
    init(event: EventListing) {
        self.event = event
        self.viewModel = EventResultViewModel(event: event)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(self.viewModel.rankings, id: \.self) { ranking in
                    HStack {
                        Text(ranking.competitor.name)
                        Spacer()
                        Text(ranking.score.formatted())
                    }
                }
            }
        }
        .task {
            self.viewModel.fetchResults()
        }
        .navigationTitle(event.name)
    }
}

struct EventResults_Previews: PreviewProvider {
    static var previews: some View {
        EventResults(event: EventListing(id: "1188",
                                         categories: Category.allCases,
                                         dateStart: Date(),
                                         dateEnd: Date(),
                                         name: "QE R61 Frontier Climbing and Fitness"))
    }
}
