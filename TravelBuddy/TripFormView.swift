//
//  TripFormView.swift
//  TravelBuddy
//
//  Created by Sahajpreet Singh Khasria on 3/30/25.
//

import SwiftUI

struct TripFormView: View {
    @StateObject var viewModel = TripPlannerViewModel()
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var budgetLevels = ["Low", "Medium", "High"]
    @State private var transportationModes = ["Car", "Train", "Plane", "Boat"]
    @State private var selectedBudgetLevel: String = "Low"
    @State private var selectedTransportationMode: String = "Plane"
    @State private var travelerCount: Int = 1
    @State private var additionalInfo: String = ""
    @State private var startLocation: String = ""
    
    // Destination is now a regular state property
    @State private var destination: String
    
    // Sheet & Alert
    @State private var showSheet = false
    @State private var showError = false
    
    init(destination: String = "") {
        _destination = State(initialValue: destination)
    }
    
    var body: some View {
        Form {
            Section {
                TextField("Start Origin", text: $startLocation)
                TextField("Destination", text: $destination)
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                Stepper("Traveler Count: \(travelerCount)", value: $travelerCount, in: 1...20)
                
                Picker("Budget Level", selection: $selectedBudgetLevel) {
                    ForEach(budgetLevels, id: \.self) { level in
                        Text(level)
                    }
                }
                
                Picker("Transportation Mode", selection: $selectedTransportationMode) {
                    ForEach(transportationModes, id: \.self) { mode in
                        Text(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Additional Preferences")) {
                TextEditor(text: $additionalInfo)
                    .frame(height: 220)
            }
            
            Button(action: makePlan) {
                HStack {
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Make Plan")
                            .foregroundStyle(.white)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
        .navigationTitle("Plan A New Trip")
        .sheet(isPresented: $showSheet) {
            if let input = viewModel.lastInput {
                TripDetailView(viewModel: viewModel, travelInput: input)
            }
        }
        .alert("Failed to generate plan", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please check your connection or try again.")
        }
    }
    
    func makePlan() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let input = TripInput(
            origin: startLocation,
            destination: destination,
            startDate: formatter.string(from: startDate),
            endDate: formatter.string(from: endDate),
            travelerCount: travelerCount,
            budgetLevel: selectedBudgetLevel,
            transportType: selectedTransportationMode,
            additionalInfo: additionalInfo
        )
        
        viewModel.fetchTravelPlan(for: input) { success in
            if success {
                showSheet = true
            } else {
                showError = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        TripFormView()
    }
    .environmentObject(TripDataService())
}
