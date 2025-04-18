//
//  LandingView.swift
//  TravelBuddy
//
//  Created by Sahajpreet Singh Khasria on 3/30/25.
//

import SwiftUI

struct LandingView: View {
    @Binding var path: NavigationPath
    @State private var items: [TripInput] = []
    @EnvironmentObject var tripDataService: TripDataService
    @State private var isLoading = false
    //var items: [TripInput]
    var prefilledTripLocations: [String] = ["New York", "Paris", "Rome", "Tokyo", "Barcelona"]
    var body: some View {
        VStack {
            HStack(spacing: 95) {
                Image("logo")
                    .resizable()
                    .frame(width: 150, height: 80)
                    .padding()
                
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .padding()
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(prefilledTripLocations, id: \.self) { location in
                        NavigationLink(destination: TripFormView(path: $path, destination: .constant(location))) {
                            VStack {
                            
                                Image(location)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 300, height: 200)
                                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
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
            NavigationLink(destination: TripFormView(path: $path, destination: .constant(""))) {
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

            
            HStack {
                Text("Recent Trips")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding()
                Spacer()
            }
            
            /*VStack {
                ForEach(items.prefix(3), id: \.self) { item in
                    NavigationLink(destination: TripDetailView(trip: item)) {
                        TripRowView(trip: item)
                    }
                }
            }*/
            
            
            NavigationLink(destination: HistoryView(path: $path)) {
                Text("See All>")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.black)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2) // Optional: Adds shadow for aesthetics
                
            }
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
                items = trips
            case .failure(let error):
                print("Error loading trips: \(error.localizedDescription)")
            }
        }
    }
}

//#Preview {
//    LandingView(path: .constant(NavigationPath()), items: [TripInput(
//        origin: "Phoenix",
//        destination: "Maldives",
//        startDate: "Today", // Or use DateFormatter to convert Date to String
//        endDate: "Tomorrow",
//        travelerCount: 2, // Added default value
//        budgetLevel: "Medium", // Added default value
//        transportType: "Plane", // Added default value
//        additionalInfo: "" // Empty by default
//    ),
//    TripInput(
//        origin: "Phoenix",
//        destination: "New York",
//        startDate: "Today",
//        endDate: "Tomorrow",
//        travelerCount: 2,
//        budgetLevel: "Medium",
//        transportType: "Plane",
//        additionalInfo: ""
//    )])
//}
