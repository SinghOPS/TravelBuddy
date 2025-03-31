//
//  TripFormView.swift
//  TravelBuddy
//
//  Created by Sahajpreet Singh Khasria on 3/30/25.
//

import SwiftUI

struct TripFormView: View {
    @Binding var path: NavigationPath
    var destination: String?
    @State var budgetLevels = ["Low", "Medium", "High"]
    @State var transportationModes = ["Car", "Train", "Plane", "Boat"]
    @State var selectedBudgetLevel: String = "Low"
    @State var selectedTransportationMode: String = "Plane"
    @State var travelerCount: Int = 0
    @State var additionalInfo: String = ""
    var destinationBinder: Binding<String> {
        Binding (
            get: { destination! },
            set: { _ in}
        )
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Plan A New Trip")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                Spacer()
            }
            .padding()
            
            Form {
                Section {
                    TextField("Destination", text: destinationBinder)
                    DatePicker("Start Date", selection: .constant(Date()), displayedComponents: .date)
                    DatePicker("End Date", selection: .constant(Date()), displayedComponents: .date)
                    Stepper("Traveler Count: \(travelerCount)", value: $travelerCount, in: 0...100)
                        .font(.headline)
                    Picker("Budget Level", selection: $selectedBudgetLevel) {
                        ForEach(budgetLevels, id: \.self) { level in
                            Text(level)
                        }
                    }
                    Picker("Transportation Mode", selection: $selectedTransportationMode) {
                        ForEach(transportationModes, id: \.self) { mode in
                            Text(mode)
                                .font(.title)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Additional Preferences") {
                    TextEditor(text: $additionalInfo)
                        .frame(height: 250)
                }
            }
            
            Button(action: { print("Saving Trip...") }) {
                HStack {
                    Spacer()
                    Text("Make Plan")
                        .foregroundStyle(.white)
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(10)
                .background(Color.blue)
                .cornerRadius(10)
            }
            .padding(.horizontal)
              
        }
            
    }
}


#Preview {
    TripFormView(path: .constant(NavigationPath()) ,destination: "")
}
