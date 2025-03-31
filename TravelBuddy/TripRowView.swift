//
//  TripRowView.swift
//  TravelBuddy
//
//  Created by Aarav Bodla on 3/30/25.
//

import SwiftUI

struct TripRowView: View {
    var trip: Trip
    
    var body: some View {
        HStack {
            Spacer()
            Image(trip.image) // Display the associated image
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Spacer()
            VStack(alignment: .leading) {
                Text(trip.Destination)
                    .font(.headline)
                    .foregroundColor(.white)
                
                // Format dates to show only day and month
                Text("\(trip.StartDate.formatted(.dateTime.month().day())) - \(trip.EndDate.formatted(.dateTime.month().day()))")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            
            Divider()
                .frame(height: 50)
                .background(Color.white)
            
            VStack {
                Text("Total Savings :")
                Text("$\(trip.totalSavings, specifier: "%.2f")")
                    .foregroundColor(.green)
                    .fontWeight(.bold)
            }
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
    TripRowView(trip: .init(Destination: "Maldives", StartDate: Date(), EndDate: Date(timeIntervalSinceNow: 86400), totalSavings: 1000, image: "Default"))
}
