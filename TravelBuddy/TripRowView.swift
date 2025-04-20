//
//  TripRowView.swift
//  TravelBuddy
//
//  Created by Aarav Bodla on 3/30/25.
//

import SwiftUI

struct TripRowView: View {
    var trip: TripInputWithItinerary
    
    var body: some View {
        HStack {
            // Airplane icon
            Image(systemName: "airplane")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.blue)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.destination)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text("\(trip.startDate) - \(trip.endDate)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Calendar icon instead of chevron
            Image(systemName: "calendar")
                .foregroundColor(.blue.opacity(0.7))
        }
        .padding(12)
        .cornerRadius(12)
        .shadow(color: .blue.opacity(0.2), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.vertical, 4)
        
    }
}

#Preview {
    TripRowView(trip: TripInputWithItinerary(
        origin: "Phoenix",
        destination: "New York",
        startDate: "Today",
        endDate: "Tomorrow",
        travelerCount: 2,
        budgetLevel: "Medium",
        transportType: "Plane",
        additionalInfo: "",
        itinerary: [],
        travelPlan: "",
        destinationImageUrl: nil
    ))
}
