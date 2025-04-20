//
//  SavedTripDetailView.swift
//  TravelBuddy
//
//  Created by Aarav Bodla on 4/19/25.
//

import SwiftUI

struct SavedTripDetailView: View {
    let trip: TripInputWithItinerary
    @State private var destinationImage: UIImage?
    @State private var isLoadingImage = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Destination Header
                destinationHeader
                
                // Trip Summary Card
                tripSummaryCard
                
                // Itinerary Section
                itinerarySection
            }
            .padding(.horizontal)
        }
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            loadDestinationImage()
        }
    }
    
    private var destinationHeader: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = destinationImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipped()
            } else {
                Color.gray.opacity(0.3)
                    .frame(height: 220)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
            }
            
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 220)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.destination)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(dateRange)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding()
        }
        .cornerRadius(12)
        .padding(.top)
        .shadow(radius: 8)
    }
    
    private var tripSummaryCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Trip Summary")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.bottom, 4)
                
                infoRow(icon: "person.2.fill",
                        text: "\(trip.travelerCount) traveler\(trip.travelerCount > 1 ? "s" : "")")
                
                infoRow(icon: "dollarsign.circle.fill",
                        text: "\(trip.budgetLevel.capitalized) budget")
                
                infoRow(icon: transportationIcon,
                        text: trip.transportType.capitalized)
                
                if !trip.additionalInfo.isEmpty {
                    infoRow(icon: "heart.fill",
                            text: trip.additionalInfo)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var itinerarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Itinerary")
                .font(.title2)
                .fontWeight(.semibold)
            
            if trip.itinerary.isEmpty {
                Text(trip.travelPlan)
                    .font(.body)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
            } else {
                ForEach(trip.itinerary) { day in
                    dayCard(for: day)
                }
            }
        }
        .padding(.bottom)
    }
    
    private func dayCard(for day: DayItinerary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(day.dayNumber)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(day.date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(day.activities) { activity in
                    activityRow(activity: activity)
                }
            }
            
            if !day.tip.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 14))
                    Text(day.tip)
                        .font(.caption)
                        .italic()
                        .frame(minWidth: 300)
                }
                .multilineTextAlignment(.center)
                .padding(.top, 4)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func activityRow(activity: Activity) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(.blue)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.time)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(activity.description)
                    .font(.body)
                
                if let cost = activity.cost {
                    Text(cost)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func infoRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func loadDestinationImage() {
        guard let imageUrl = trip.destinationImageUrl else { return }
        isLoadingImage = true
        
        URLSession.shared.dataTask(with: URL(string: imageUrl)!) { data, _, error in
            DispatchQueue.main.async {
                isLoadingImage = false
                if let data = data, let image = UIImage(data: data) {
                    destinationImage = image
                }
            }
        }.resume()
    }
    
    private var dateRange: String {
        "\(trip.startDate) - \(trip.endDate)"
    }
    
    private var transportationIcon: String {
        switch trip.transportType.lowercased() {
        case "plane": return "airplane"
        case "train": return "tram.fill"
        case "car": return "car.fill"
        case "bus": return "bus.fill"
        default: return "figure.walk"
        }
    }
}

//#Preview {
//    SavedTripDetailView(trip: TripPlannerViewModel.TripInputWithItinerary(
//        origin: "New York",
//        destination: "Paris",
//        startDate: "20 Apr 2025",
//        endDate: "25 Apr 2025",
//        travelerCount: 2,
//        budgetLevel: "Medium",
//        transportType: "Plane",
//        additionalInfo: "Interested in art and local cuisine",
//        itinerary: [
//            DayItinerary(
//                dayNumber: "Day 1",
//                date: "04/20",
//                activities: [
//                    Activity(time: "8:00AM", description: "Breakfast at Café Central", cost: "$15"),
//                    Activity(time: "1:00PM", description: "Guided city tour", cost: "$25"),
//                    Activity(time: "7:00PM", description: "Dinner at Seafood Grill", cost: "$45")
//                ],
//                tip: "Purchase museum tickets online to skip the lines"
//            )
//        ],
//        travelPlan: "Sample travel plan",
//        destinationImageUrl: nil
//    ))
//}
