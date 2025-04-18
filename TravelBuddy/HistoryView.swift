//
//  HistoryView.swift
//  TravelBuddy
//
//  Created by Sahajpreet Singh Khasria on 3/30/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Binding var path: NavigationPath
    @EnvironmentObject var tripDataService: TripDataService
    @State private var trips: [TripInput] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            List {
                if isLoading {
                    ProgressView()
                } else if trips.isEmpty {
                    Text("No saved trips yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(trips) { trip in
                        NavigationLink(destination: TripDetailView(
                            viewModel: TripPlannerViewModel(),
                            travelInput: trip
                        )) {
                            TripRowView(trip: trip)
                        }
                    }
                    .onDelete(perform: deleteTrip)
                }
            }
            .navigationTitle("Saved Trips")
            .toolbar {
                EditButton()
            }
            .onAppear {
                loadTrips()
            }
        }
    }
    
    private func loadTrips() {
        isLoading = true
        tripDataService.fetchTrips { result in
            isLoading = false
            switch result {
            case .success(let fetchedTrips):
                trips = fetchedTrips
            case .failure(let error):
                print("Error loading trips: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteTrip(at offsets: IndexSet) {
        offsets.forEach { index in
            let trip = trips[index]
            tripDataService.deleteTrip(trip) { _ in
                // Handle completion if needed
            }
        }
        trips.remove(atOffsets: offsets)
    }
}

#Preview {
    HistoryView(path: .constant(NavigationPath()))
        .environmentObject(TripDataService())
}

//#Preview {
//    HistoryView(path: .constant(NavigationPath()),items: [Trip(Destination: "Maldives", StartDate: Date(), EndDate: Date(timeIntervalSinceNow: 86400), totalSavings: 1000,image: "Default"), Trip(Destination: "New York", StartDate: Date(), EndDate: Date(timeIntervalSinceNow: 86400), totalSavings: 100,image: "Default")])
//}
