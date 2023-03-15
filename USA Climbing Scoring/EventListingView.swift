//
//  EventListingView.swift
//  USA Climbing Scoring
//
//  Created by Jon Rexeisen on 3/14/23.
//

import SwiftUI

struct EventListingView: View {
    var viewModel = EventListingViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                Section("Current") {
                    ForEach(viewModel.currentEvents, id: \.self) { event in
                        NavigationLink(destination: EventResults(event: event)) {
                            
                            Text(event.name)
                        }
                    }
                }
            }
            .navigationTitle("Events")
        }
    }
}

struct EventListing_Previews: PreviewProvider {
    static var previews: some View {
        EventListingView()
    }
}

