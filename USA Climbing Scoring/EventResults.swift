//
//  EventResults.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/14/23.
//

import SwiftUI

struct EventResults: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    var event: EventListing
    @ObservedObject var viewModel: EventResultViewModel
    
    init(event: EventListing) {
        self.event = event
        self.viewModel = EventResultViewModel(event: event)
    }
    
    var body: some View {
        Group {
            if verticalSizeClass == .regular && horizontalSizeClass == .compact {
                List {
                    ForEach(self.viewModel.rankings, id: \.self) { ranking in
                        if (1...3).contains(self.viewModel.places[ranking.score] ?? 0) {
                            MedalRow(place: self.viewModel.places[ranking.score] ?? 0, ranking: ranking)
                        } else {
                            if ranking.competitor.scratch {
                                Text(ranking.competitor.name)
                                    .strikethrough()
                            } else {
                                HStack {
                                    Text("\(self.viewModel.places[ranking.score] ?? 0)")
                                    Text(ranking.competitor.name)
                                    Spacer()
                                    Text(ranking.description)
                                        .monospacedDigit()
                                }
                            }
                        }
                    }
                }
            } else {
                ScrollView {
                    Grid {
                        GridRow {
                            Text("Place")
                            Text("Name")
                                .gridColumnAlignment(.leading)
                            Text("Score")
                            ForEach(self.viewModel.routes, id: \.self) { routeName in
                                Text(routeName)
                            }
                        }
                        Divider()
                        
                        ForEach(self.viewModel.rankings, id: \.self) { (ranking: Ranking) in
                            GridRow {
                                if ranking.competitor.scratch {
                                    Spacer()
                                    Text(ranking.competitor.name)
                                        .strikethrough()
                                    Spacer()
                                } else {
                                    Text("\(self.viewModel.places[ranking.score] ?? 0)")
                                    Text(ranking.competitor.name)
                                    Text(ranking.description)
                                        .monospacedDigit()
                                    ForEach(self.viewModel.routes, id: \.self) { routeName in
                                        Text("\(ranking.routeCards.first(where: {$0.routeId == routeName})?.bestAttempt?.score ?? "0") \(ranking.place[routeName]?.formatted(.number.precision(.fractionLength(2))) ?? "0")")
                                    }
//                                    ForEach(ranking.place.sorted(by: >), id: \.key) { key, value in
//                                        Text(value.value.formatted(.number.precision(.fractionLength(2))))
//                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .task {
            self.viewModel.fetchResults()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(event.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    ForEach(self.viewModel.categories, id: \.self) { category in
                        Button(action: {
                            self.viewModel.currentCategory = category
                        }) {
                            if category == self.viewModel.currentCategory {
                                Label(category.rawValue, systemImage: "checkmark")
                            }else {
                                Text(category.rawValue)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(self.viewModel.currentCategory.rawValue)
                        Image(systemName: "chevron.up.chevron.down")
                    }
                }

            }
        }
    }
}

struct MedalRow: View {
    var place: Int
    var ranking: Ranking
    
    var body: some View {
        HStack {
            if place == 1 {
                Image(systemName: "medal")
                    .symbolVariant(.fill)
                    .foregroundColor(.yellow)
            } else if place == 2 {
                Image(systemName: "medal")
                    .symbolVariant(.fill)
                    .foregroundColor(.gray)
            } else {
                Image(systemName: "medal")
                    .symbolVariant(.fill)
                    .foregroundColor(.brown)
            }
            Text(ranking.competitor.name)
                .fontWeight(.semibold)
            Spacer()
            Text(ranking.description)
                .monospacedDigit()
        }
    }
}

struct EventResults_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventResults(event: EventListing(id: "1188",
                                             categories: Category.allCases,
                                             dateStart: Date(),
                                             dateEnd: Date(),
                                             name: "QE R61 Frontier Climbing and Fitness",
                                             isLocal: true))
        }
    }
}
