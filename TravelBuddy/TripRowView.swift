//
//  TripRowView.swift
//  TravelBuddy
//
//  Created by Aarav Bodla on 3/30/25.
//

import SwiftUI

struct TripRowView: View {
    var trip: TripInput
    
    var body: some View {
        HStack {
            Spacer()
            Image("Default") // Display the associated image
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Spacer()
            VStack(alignment: .leading) {
                Text(trip.destination)
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Format dates to show only day and month
                Text("\(trip.startDate) - \(trip.endDate)")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            
            Divider()
                .frame(height: 50)
                .background(Color.white)
            Spacer()
        }
        .padding(.vertical, 6)
        .foregroundStyle(Color.white)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}

#Preview {
    TripRowView(trip: .init(origin: "Phoenix",
                            destination: "New York",
                            startDate: "Today",
                            endDate: "Tomorrow",
                            travelerCount: 2,
                            budgetLevel: "Medium",
                            transportType: "Plane",
                            additionalInfo: ""))
}
