//
//  TravelBuddyApp.swift
//  TravelBuddy
//
//  Created by Sahajpreet Singh Khasria on 3/30/25.
//

import SwiftUI
import FirebaseCore

@main
struct TravelBuddyApp: App {
    @StateObject private var authService = AuthService()
    @StateObject private var tripDataService = TripDataService()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(tripDataService)
        }
    }
}
