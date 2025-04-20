//
//  ContentView.swift
//  TravelBuddy
//
//  Created by Sahajpreet Singh Khasria on 3/30/25.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var authService = AuthService()
    
    var body: some View {
        NavigationStack {
            Group {
                if authService.isAuthenticated {
                    LandingView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authService)
        }
    }
}
#Preview {
    ContentView()
        
}
