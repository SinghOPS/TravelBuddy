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
    var image: String
    
    init(Destination: String, StartDate: Date, EndDate: Date, totalSavings: Double, image: String) {
        self.Destination = Destination
        self.StartDate = StartDate
        self.EndDate = EndDate
        self.totalSavings = totalSavings
        self.image = image
    }
    
}
