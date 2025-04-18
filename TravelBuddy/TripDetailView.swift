//
//  TripDetailView.swift
//  TravelBuddy
//
//  Created by Aarav Bodla on 3/30/25.
//

import Foundation
import SwiftUI

struct TripDetailView: View {
    @ObservedObject var viewModel: TripPlannerViewModel
    let travelInput: TripInput
    @State private var showErrorAlert = false
    @State private var showSaveSuccess = false
    @EnvironmentObject var tripDataService: TripDataService
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Destination Header
                    destinationHeader
                        .onAppear {
                            viewModel.fetchDestinationImage(destination: travelInput.destination)
                        }
                    
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
            .alert("Plan Generation Failed",
                   isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("We couldn't generate a plan. Please try again later.")
            }
            .onAppear {
                if viewModel.travelPlan.isEmpty && !viewModel.isLoading {
                    showErrorAlert = true
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var destinationHeader: some View {
        ZStack(alignment: .bottomLeading) {
            // Dynamic image based on destination or placeholder
            // Display the fetched image or placeholder
            if let image = viewModel.destinationImage {
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
                Text(travelInput.destination)
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
                        text: "\(travelInput.travelerCount) traveler\(travelInput.travelerCount > 1 ? "s" : "")")
                
                infoRow(icon: "dollarsign.circle.fill",
                        text: "\(travelInput.budgetLevel.capitalized) budget")
                
                infoRow(icon: transportationIcon,
                        text: travelInput.transportType.capitalized)
                
                if !travelInput.additionalInfo.isEmpty {
                    infoRow(icon: "heart.fill",
                            text: travelInput.additionalInfo)
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
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if !viewModel.parsedItinerary.isEmpty {
                ForEach(viewModel.parsedItinerary) { day in
                    dayCard(for: day)
                }
            } else if !viewModel.travelPlan.isEmpty {
                // Fallback for unparsed but successful response
                Text(viewModel.travelPlan)
                    .font(.body)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
            } else {
                Text("No itinerary generated yet")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.bottom)
    }
    
    private func dayCard(for day: TripPlannerViewModel.DayItinerary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Day Header
            HStack {
                Text(day.dayNumber)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(day.date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Activities
            VStack(alignment: .leading, spacing: 8) {
                ForEach(day.activities) { activity in
                    activityRow(activity: activity)
                }
            }
            
            // Tip (if available)
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
    
    private func activityRow(activity: TripPlannerViewModel.Activity) -> some View {
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
    
    // MARK: - Computed Properties
    
    private var dateRange: String {
        "\(travelInput.startDate) - \(travelInput.endDate)"
    }
    
    private var transportationIcon: String {
        switch travelInput.transportType.lowercased() {
        case "plane": return "airplane"
        case "train": return "tram.fill"
        case "car": return "car.fill"
        case "bus": return "bus.fill"
        default: return "figure.walk"
        }
    }
}

// MARK: - Preview

#Preview {
    let mockViewModel = TripPlannerViewModel()
    mockViewModel.parsedItinerary = [
        TripPlannerViewModel.DayItinerary(
            dayNumber: "Day 1",
            date: "04/20",
            activities: [
                TripPlannerViewModel.Activity(time: "8:00AM", description: "Breakfast at Café Central", cost: "$15"),
                TripPlannerViewModel.Activity(time: "1:00PM", description: "Guided city tour", cost: "$25"),
                TripPlannerViewModel.Activity(time: "7:00PM", description: "Dinner at Seafood Grill", cost: "$45")
            ],
            tip: "Purchase museum tickets online to skip the lines"
        ),
        TripPlannerViewModel.DayItinerary(
            dayNumber: "Day 2",
            date: "04/21",
            activities: [
                TripPlannerViewModel.Activity(time: "9:00AM", description: "Visit the art museum", cost: "$18"),
                TripPlannerViewModel.Activity(time: "1:00PM", description: "Lunch at Local Bistro", cost: "$22"),
                TripPlannerViewModel.Activity(time: "6:00PM", description: "Sunset boat cruise", cost: "$35")
            ],
            tip: "Wear comfortable shoes for museum walking"
        )
    ]
    
    return TripDetailView(
        viewModel: mockViewModel,
        travelInput: TripInput(
            origin: "New York",
            destination: "Paris",
            startDate: "20 Apr 2025",
            endDate: "25 Apr 2025",
            travelerCount: 2,
            budgetLevel: "Medium",
            transportType: "Plane",
            additionalInfo: "Interested in art and local cuisine"
        )
    )
}
