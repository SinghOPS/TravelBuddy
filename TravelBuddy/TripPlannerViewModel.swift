//
//  TripPlannerViewModel.swift
//  TravelBuddy
//
// AIzaSyBGHsw-_X9ydBVrd2cDhGkLr16ClmRAoq0
//  Created by Sahajpreet Singh Khasria on 4/16/25.
// Final URL: https://pixabay.com/api/?key=49793310-dbc0f778b860ad57baa236cdd&q=Paris&image_type=photo&per_page=1&orientation=horizontal
//

import MapKit
import SwiftUI
import Foundation
import Combine

class TripPlannerViewModel: ObservableObject {
    @Published var travelPlan: String = ""
    @Published var isLoading = false
    @Published var parsedItinerary: [DayItinerary] = []
    @Published var destinationImage: UIImage?
    @Published var isLoadingImage = false
    @Published var imageError: String?
    @Published var destinationImageUrl: String?
    private var cancellables = Set<AnyCancellable>()
    var lastInput: TripInput? = nil

    private let apiKey = "AIzaSyBGHsw-_X9ydBVrd2cDhGkLr16ClmRAoq0"
    private let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    private let pixabayKey = "49793310-dbc0f778b860ad57baa236cdd"
    private let pixabayEndpoint = "https://pixabay.com/api/"

    // Data models for parsed itinerary
    
    

    func fetchTravelPlan(for input: TripInput, completion: @escaping (Bool) -> Void) {
        isLoading = true
        travelPlan = ""
        parsedItinerary = []
        lastInput = input

        let prompt = generatePrompt(from: input)

        guard let url = URL(string: "\(endpoint)?key=\(apiKey)") else {
            DispatchQueue.main.async {
                self.travelPlan = "Invalid API endpoint."
                completion(false)
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 5000
            ]
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload) else {
            DispatchQueue.main.async {
                self.travelPlan = "Failed to encode request body."
                completion(false)
            }
            return
        }

        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.travelPlan = "Could not connect to the API."
                    completion(false)
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.travelPlan = "No data received from the API."
                    completion(false)
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let candidates = json["candidates"] as? [[String: Any]],
                   let content = candidates.first?["content"] as? [String: Any],
                   let parts = content["parts"] as? [[String: Any]],
                   let text = parts.first?["text"] as? String {
                    DispatchQueue.main.async {
                        let cleanText = text
                            .replacingOccurrences(of: "*", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        self.travelPlan = cleanText
                        self.parseItinerary(from: cleanText)
                        completion(true)
                    }
                } else if let errorJson = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let errorMessage = errorJson["error"] as? String {
                    print("❌ API error: \(errorMessage)")
                    DispatchQueue.main.async {
                        self.travelPlan = "Error: \(errorMessage)"
                        completion(false)
                    }
                } else {
                    let rawString = String(data: data, encoding: .utf8) ?? "Unreadable"
                    print("⚠️ Unexpected response:\n\(rawString)")
                    DispatchQueue.main.async {
                        self.travelPlan = "Unexpected API response format."
                        completion(false)
                    }
                }
            } catch {
                print("❌ JSON decode error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.travelPlan = "Failed to decode response."
                    completion(false)
                }
            }
        }.resume()
    }

    private func parseItinerary(from text: String) {
        var days: [DayItinerary] = []
        let dayBlocks = text.components(separatedBy: "\n\n").filter { !$0.isEmpty }
        
        for block in dayBlocks {
            if let day = parseDayBlock(block) {
                days.append(day)
            }
        }
        
        parsedItinerary = days
    }
    
    private func parseDayBlock(_ block: String) -> DayItinerary? {
        let lines = block.components(separatedBy: .newlines).filter { !$0.isEmpty }
        guard lines.count >= 4 else { return nil }
        
        // Parse day header (e.g., "Day 1: 04/20")
        let dayHeader = lines[0]
        let dayComponents = dayHeader.components(separatedBy: ": ")
        guard dayComponents.count == 2 else { return nil }
        let dayNumber = dayComponents[0].trimmingCharacters(in: .whitespaces)
        let date = dayComponents[1].trimmingCharacters(in: .whitespaces)
        
        // Parse activities
        var activities: [Activity] = []
        var tip = ""
        
        for i in 1..<lines.count {
            let line = lines[i]
            
            if line.hasPrefix("★ Tip:") {
                tip = line.replacingOccurrences(of: "★ Tip:", with: "").trimmingCharacters(in: .whitespaces)
                continue
            }
            
            if line.hasPrefix("•") {
                let activity = parseActivityLine(line)
                activities.append(activity)
            }
        }
        
        guard !activities.isEmpty else { return nil }
        
        return DayItinerary(
            dayNumber: dayNumber,
            date: date,
            activities: activities,
            tip: tip
        )
    }
    
    private func parseActivityLine(_ line: String) -> Activity {
        let cleanedLine = line
            .replacingOccurrences(of: "•", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        // Split into time and description parts
        let components = cleanedLine.components(separatedBy: ": ")
        guard components.count >= 2 else {
            return Activity(time: "", description: cleanedLine, cost: nil)
        }
        
        // Extract time (first component)
        let rawTime = components[0]
        let time = formatTime(rawTime)
        
        // Rebuild description from remaining components
        let descriptionWithCost = components.dropFirst().joined(separator: ": ")
        
        // Extract cost
        let (cleanDescription, cost) = extractCost(from: descriptionWithCost)
        
        return Activity(
            time: time,
            description: cleanDescription,
            cost: cost
        )
    }

    private func formatTime(_ rawTime: String) -> String {
        // Handle times like "8AM", "230PM", "12:30PM"
        let cleaned = rawTime
            .replacingOccurrences(of: ":", with: "")
            .uppercased()
        
        guard let hourMinuteRange = cleaned.range(of: "\\d+", options: .regularExpression),
              let ampmRange = cleaned.range(of: "[AP]M", options: .regularExpression) else {
            return rawTime // fallback
        }
        
        let hourMinute = String(cleaned[hourMinuteRange])
        let ampm = String(cleaned[ampmRange])
        
        // Format with colon if needed
        if hourMinute.count > 2 {
            let hour = String(hourMinute.prefix(hourMinute.count - 2))
            let minute = String(hourMinute.suffix(2))
            return "\(hour):\(minute)\(ampm)"
        }
        
        return "\(hourMinute)\(ampm)"
    }

    private func extractCost(from text: String) -> (description: String, cost: String?) {
        let pattern = "\\(Cost: \\$(\\d+)\\)"
        guard let range = text.range(of: pattern, options: .regularExpression) else {
            return (text.trimmingCharacters(in: .whitespaces), nil)
        }
        
        let costText = String(text[range])
        let cost = costText
            .replacingOccurrences(of: "(Cost: $", with: "")
            .replacingOccurrences(of: ")", with: "")
        
        let cleanDescription = text
            .replacingCharacters(in: range, with: "")
            .trimmingCharacters(in: .whitespaces)
        
        return (cleanDescription, "$\(cost)")
    }
    private func formatTimeForDisplay(_ time: String) -> String {
        // Convert "8am" → "8AM", "230pm" → "2:30PM"
        let cleaned = time.replacingOccurrences(of: ":", with: "")
        guard let hourMinuteRange = cleaned.range(of: "\\d+", options: .regularExpression),
              let ampmRange = cleaned.range(of: "[AP]M", options: .regularExpression) else {
            return time.uppercased()
        }
        
        let hourMinute = String(cleaned[hourMinuteRange])
        let ampm = String(cleaned[ampmRange]).uppercased()
        
        // Insert colon if needed (for times like "230pm" → "2:30")
        if hourMinute.count > 2 {
            let hour = String(hourMinute.prefix(hourMinute.count - 2))
            let minute = String(hourMinute.suffix(2))
            return "\(hour):\(minute)\(ampm)"
        }
        
        return "\(hourMinute)\(ampm)"
    }

    private func generatePrompt(from input: TripInput) -> String {
        return """
        You are a travel planning assistant. Also, account in the cost for travel into and out of destination. Based on the following information, generate a detailed and practical itinerary with the following STRICT FORMATTING RULES:

        ### REQUIRED FORMAT
        Day [N]: [MM/DD]
        • [TIME]: [ACTIVITY DESCRIPTION] (Cost: $XX)
        • [TIME]: [ACTIVITY DESCRIPTION] (Cost: $XX)
        • [TIME]: [ACTIVITY DESCRIPTION] (Cost: $XX)
        ★ Tip: [TIP TEXT]

        [BLANK LINE BETWEEN DAYS]

        ### STRICT RULES
        1. TIME FORMAT:
        - Must use EXACTLY "8:00AM" or "2:30PM" format
        - Always include colon and two-digit minutes
        - Must end with AM/PM in uppercase

        2. ACTIVITY FORMAT:
        - After time, put ": " (colon + space)
        - Never include additional colons in description

        3. COST FORMAT:
        - Must be EXACTLY "(Cost: $XX)" at end of each activity
        - Use whole dollar amounts only

        4. CONTENT RULES:
        - Budget: \(input.budgetLevel) appropriate activities
        - Transportation: Optimize for \(input.transportType)
        \(input.additionalInfo.isEmpty ? "" : "- MUST include: \(input.additionalInfo)")

        5. OTHER:
        - Always start with "• " (bullet + space)
        - Exactly 3 activities per day
        - One tip per day starting with "★ Tip: "
        
        ### EXAMPLE (COPY THIS EXACTLY)
        Day 1: 04/20
        • 8:00AM: Breakfast at café (Cost: $15)
        • 1:00PM: Museum visit (Cost: $25)
        • 7:30PM: Seafood dinner (Cost: $45)
        ★ Tip: Buy tickets in advance
        
        ### TRIP DETAILS
        Origin: \(input.origin)
        Destination: \(input.destination)
        Dates: \(input.startDate) to \(input.endDate)
        Travelers: \(input.travelerCount)
        Budget: \(input.budgetLevel)
        Transport: \(input.transportType)
        
        ### BEGIN ITINERARY
        """
    }
    
    func fetchDestinationImage(destination: String) {
        guard destinationImage == nil else { return }
        isLoadingImage = true
        imageError = nil
        
        let query = destination
            .components(separatedBy: ",")
            .first?
            .trimmingCharacters(in: .whitespaces) ?? destination
        
        // Use standard encoding directly:
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(pixabayEndpoint)?key=\(pixabayKey)&q=\(encodedQuery)&image_type=photo&per_page=3&orientation=horizontal") else {
            imageError = "Invalid URL"
            isLoadingImage = false
            return
        }
        print("DEBUG - API URL: \(url.absoluteString)")
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                guard response.statusCode == 200 else {
                    if response.statusCode == 429 {
                        throw ImageError.rateLimited
                    }
                    throw ImageError.invalidResponse(code: response.statusCode)
                }
                return output.data
            }
            .decode(type: PixabayResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoadingImage = false
                if case .failure(let error) = completion {
                    self?.imageError = error.localizedDescription
                }
            } receiveValue: { [weak self] response in
                if response.hits.isEmpty {
                    self?.imageError = "No images found"
                } else if let imageUrl = response.hits.first?.webformatURL {
                    self?.downloadImage(from: imageUrl)
                }
            }
            .store(in: &cancellables)
    }
    
    private func downloadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            imageError = "Invalid image URL"
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoadingImage = false
                
                if let error = error {
                    self?.imageError = error.localizedDescription
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    self?.imageError = "Failed to decode image"
                    return
                }
                
                self?.destinationImage = image
                self?.destinationImageUrl = urlString
                self?.imageError = nil
            }
        }.resume()
    }
    
    enum ImageError: LocalizedError {
        case rateLimited
        case invalidResponse(code: Int)
        
        var errorDescription: String? {
            switch self {
            case .rateLimited:
                return "API rate limit exceeded"
            case .invalidResponse(let code):
                return "Server returned \(code)"
            }
        }
    }
}

    // Pixabay API Models
    struct PixabayResponse: Codable {
        let total: Int
        let totalHits: Int
        let hits: [PixabayImage]
    }

    struct PixabayImage: Codable {
        let id: Int
        let webformatURL: String
        let user: String
    }

struct TripInput: Codable, Identifiable {
    let id = UUID()
    let origin: String
    let destination: String
    let startDate: String
    let endDate: String
    let travelerCount: Int
    let budgetLevel: String
    let transportType: String
    let additionalInfo: String
}

// Add these structs inside the TripPlannerViewModel class
struct DayItinerary: Identifiable, Codable {
    var id = UUID()
    let dayNumber: String
    let date: String
    let activities: [Activity]
    let tip: String
    
    enum CodingKeys: String, CodingKey {
        case dayNumber, date, activities, tip
    }
}

struct Activity: Identifiable, Codable {
    var id = UUID()
    let time: String
    let description: String
    let cost: String?
    
    enum CodingKeys: String, CodingKey {
        case time, description, cost
    }
}

// Add this outside the TripPlannerViewModel class
struct TripInputWithItinerary: Codable, Identifiable {
    let id: UUID
    let origin: String
    let destination: String
    let startDate: String
    let endDate: String
    let travelerCount: Int
    let budgetLevel: String
    let transportType: String
    let additionalInfo: String
    let itinerary: [DayItinerary]
    let travelPlan: String
    let destinationImageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, origin, destination, startDate, endDate, travelerCount,
             budgetLevel, transportType, additionalInfo, itinerary,
             travelPlan, destinationImageUrl
    }
    
    init(origin: String, destination: String, startDate: String, endDate: String,
         travelerCount: Int, budgetLevel: String, transportType: String,
         additionalInfo: String, itinerary: [DayItinerary],
         travelPlan: String, destinationImageUrl: String?) {
        self.id = UUID()
        self.origin = origin
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.travelerCount = travelerCount
        self.budgetLevel = budgetLevel
        self.transportType = transportType
        self.additionalInfo = additionalInfo
        self.itinerary = itinerary
        self.travelPlan = travelPlan
        self.destinationImageUrl = destinationImageUrl
    }
}
