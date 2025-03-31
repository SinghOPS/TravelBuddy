//
//  HistoryView.swift
//  TravelBuddy
//
//  Created by Sahajpreet Singh Khasria on 3/30/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    var items: [Trip]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink(destination: TripDetailView(trip: item)) {
                        TripRowView(trip: item)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(InsetGroupedListStyle())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Recent Trips")
        }
    }

    private func addItem() {
        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    HistoryView(items: [Trip(Destination: "Maldives", StartDate: Date(), EndDate: Date(timeIntervalSinceNow: 86400), totalSavings: 1000,image: "Default"), Trip(Destination: "New York", StartDate: Date(), EndDate: Date(timeIntervalSinceNow: 86400), totalSavings: 100,image: "Default")])
}
