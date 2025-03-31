//
//  TripDetailView.swift
//  TravelBuddy
//
//  Created by Aarav Bodla on 3/30/25.
//

import Foundation
import SwiftUI

import Foundation
import SwiftUI

struct TripDetailView: View {
    @State var trip: Trip

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Image(trip.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 5)
                    
                    Text(trip.Destination)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    Text("\(formatDate(trip.StartDate)) - \(formatDate(trip.EndDate))")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding()
                    Text(String(trip.totalSavings))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding()
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy" // Formats to "12 Apr 2025" (Day, Month, Year)
        return formatter.string(from: date)
    }
}

#Preview {
    TripDetailView(trip: Trip(
        Destination: "New York",
        StartDate: Date(),
        EndDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!, // Adds 5 days safely
        totalSavings: 120.0,
        image: "Default"
    ))
}
