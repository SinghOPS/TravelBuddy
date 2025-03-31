//
//  LandingView.swift
//  TravelBuddy
//
//  Created by Sahajpreet Singh Khasria on 3/30/25.
//

import SwiftUI

struct LandingView: View {
    @Binding var path: NavigationPath
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
                        NavigationLink(destination: TripFormView(path: $path, destination: location)) {
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
            NavigationLink(destination: TripFormView(path: $path, destination: "")) {
                Text("Plan a New Trip")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2) // Optional: Adds shadow for aesthetics
            }

            
            HStack {
                Text("Recent Trips")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .padding()
                Spacer()
            }
            
            VStack {
                
            }
            
            Button(action: {print("See all trips!")}) {
                Text("See All>")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .frame(width: 300, height: 50)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
            
        }
    }
}

#Preview {
    LandingView(path: .constant(NavigationPath()))
}
