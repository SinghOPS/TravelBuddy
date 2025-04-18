//
//  TripDataService.swift
//  TravelBuddy
//
//  Created by Aarav Bodla on 4/18/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class TripDataService: ObservableObject {
    private let db = Firestore.firestore()
    
    func saveTrip(_ trip: TripInput, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        do {
            let tripData = try Firestore.Encoder().encode(trip)
            db.collection("users").document(userId).collection("trips").addDocument(data: tripData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func fetchTrips(completion: @escaping (Result<[TripInput], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(userId).collection("trips").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let trips = snapshot?.documents.compactMap { document in
                try? Firestore.Decoder().decode(TripInput.self, from: document.data())
            } ?? []
            
            completion(.success(trips))
        }
    }
    func deleteTrip(_ trip: TripInput, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        // First find the document with matching trip data
        db.collection("users").document(userId).collection("trips")
            .whereField("id", isEqualTo: trip.id.uuidString)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Trip not found"])))
                    return
                }
                
                document.reference.delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(true))
                    }
                }
            }
    }
}
