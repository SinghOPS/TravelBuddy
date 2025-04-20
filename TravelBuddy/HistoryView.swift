//
//  HistoryView.swift
//  TravelBuddy
//
//  Created by Sahajpreet Singh Khasria on 3/30/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @EnvironmentObject var tripDataService: TripDataService
    @EnvironmentObject var authService: AuthService
    @State private var trips: [TripInputWithItinerary] = []
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
                        NavigationLink(destination: SavedTripDetailView(trip: trip)) {
                            TripRowView(trip: trip)
                        }
                    }
                    .onDelete(perform: deleteTrip)
                }
            }
            .navigationTitle("Saved Trips")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
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
    HistoryView()
        .environmentObject(TripDataService())
        .environmentObject(AuthService())
}
