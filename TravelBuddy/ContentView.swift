//
//  ContentView.swift
//  TravelBuddy
//
//  Created by Sahajpreet Singh Khasria on 3/30/25.
//

import SwiftUI


struct ContentView: View {
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            LoginView(path: $path)
        }
    }
}

#Preview {
    ContentView()
        
}
