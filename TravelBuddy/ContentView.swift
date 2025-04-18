//
//  ContentView.swift
//  TravelBuddy
//
//  Created by Sahajpreet Singh Khasria on 3/30/25.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var authService = AuthService()
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            if authService.isAuthenticated {
                LandingView(path: $path)
                    .environmentObject(authService)
            } else {
                LoginView(path: $path)
                    .environmentObject(authService)
            }
        }
    }
}

#Preview {
    ContentView()
        
}
