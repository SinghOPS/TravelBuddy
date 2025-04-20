//
//  LandingView.swift
//  TravelBuddy
//
//  Created by Sahajpreet Singh Khasria on 3/30/25.
//

import SwiftUI

struct LandingView: View {
    @EnvironmentObject var tripDataService: TripDataService
    @EnvironmentObject var authService: AuthService
    @State private var items: [TripInputWithItinerary] = []
    @State private var isLoading = false
    @State private var showLogoutAlert = false
    
    var prefilledTripLocations: [String] = ["New York", "Paris", "Rome", "Tokyo", "Barcelona"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    // Header with logo and profile
                    HStack(spacing: 95) {
                        Image("logo")
                            .resizable()
                            .frame(width: 150, height: 80)
                            .padding()
                        
                        Button(action: { showLogoutAlert = true }) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 70, height: 70)
                                .padding()
                        }
                    }
                    .alert("Log Out", isPresented: $showLogoutAlert) {
                        Button("Log Out", role: .destructive) {
                            authService.signOut()
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to log out?")
                    }
                    
                    // Popular destinations scroll view
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(prefilledTripLocations, id: \.self) { location in
                                NavigationLink(destination: TripFormView(destination: location)) {
                                    VStack {
                                        Image(location)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 300, height: 200)
                                            .padding(.leading, 10)
                                            .clipShape(RoundedRectangle(cornerRadius: 25))
                                            .shadow(color: .black.opacity(0.3), radius: 10, x: 5, y: 10)
                                        
                                        Text("Plan a trip to \(location)")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                            .padding(5)
                                    }
                                    .padding(5)
                                }
                            }
                        }
                    }
                    
                    // Plan New Trip button
                    NavigationLink(destination: TripFormView(destination: "")) {
                        Text("Plan a New Trip")
                            .font(.title2)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 300, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
                    }
                    .padding(.bottom, 20)
                    
                    // Recent Trips Section
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Recent Trips")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                            Spacer()
                            
                            NavigationLink(destination: HistoryView()) {
                                Text("See All")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else if items.isEmpty {
                            Text("No recent trips yet")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            VStack(spacing: 15) {
                                ForEach(items.prefix(3)) { trip in
                                    NavigationLink(destination: SavedTripDetailView(trip: trip)) {
                                        TripRowView(trip: trip)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .onAppear {
            loadTrips()
        }
    }
    
    private func loadTrips() {
        isLoading = true
        tripDataService.fetchTrips { result in
            isLoading = false
            switch result {
            case .success(let trips):
                items = trips.sorted {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    guard let date1 = dateFormatter.date(from: $0.startDate),
                          let date2 = dateFormatter.date(from: $1.startDate) else {
                        return false
                    }
                    return date1 > date2
                }
            case .failure(let error):
                print("Error loading trips: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    LandingView()
        .environmentObject(TripDataService())
        .environmentObject(AuthService())
}
