//
//  Item.swift
//  TravelBuddy
//
//  Created by Sahajpreet Singh Khasria on 3/30/25.
//

import Foundation
import SwiftData

@Model
final class Trip {
    var Destination: String
    var StartDate: Date
    var EndDate: Date
    var totalSavings: Double
    
    init(Destination: String, StartDate: Date, EndDate: Date, totalSavings: Double) {
        self.Destination = Destination
        self.StartDate = StartDate
        self.EndDate = EndDate
        self.totalSavings = totalSavings
    }
    
}
