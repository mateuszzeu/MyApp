//
//  DailyWeight.swift
//  Stronger
//
//  Created by Liza on 03/02/2025.
//

import Foundation

// MARK: - Model
struct DailyWeight: Identifiable {
    let id: UUID
    let date: Date
    let weight: Double?
    
    init(
        id: UUID = UUID(),
        date: Date,
        weight: Double?
    ) {
        self.id = id
        self.date = date
        self.weight = weight
    }
}

// MARK: - Dictionary Conversion
extension DailyWeight {
    
    // Converts a dictionary into a DailyWeight instance
    init?(dictionary: [String: Any]) {
        guard
            let idString = dictionary["id"] as? String,
            let uuid = UUID(uuidString: idString),
            let dateTimestamp = dictionary["date"] as? Double
        else {
            return nil
        }
        
        self.id = uuid
        self.date = Date(timeIntervalSince1970: dateTimestamp)
        self.weight = dictionary["weight"] as? Double
    }
    
    // Converts the DailyWeight instance into a dictionary
    var dictionary: [String: Any] {
        var result: [String: Any] = [
            "id": id.uuidString,
            "date": date.timeIntervalSince1970
        ]
        
        // Add weight only if it exists
        if let weight { result["weight"] = weight }
        
        return result
    }
}
