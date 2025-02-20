//
//  DailyMacros.swift
//  Stronger
//
//  Created by Liza on 22/01/2025.
//

import Foundation

// MARK: - Model
struct DailyMacros: Identifiable {
    let id: UUID
    let date: Date
    let protein: Double?
    let carbs: Double?
    let fat: Double?
    let calories: Double?
    
    init(
        id: UUID = UUID(),
        date: Date,
        protein: Double?,
        carbs: Double?,
        fat: Double?,
        calories: Double?
    ) {
        self.id = id
        self.date = date
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.calories = calories
    }
}

// MARK: - Dictionary Conversion
extension DailyMacros {
    
    // Converts a dictionary into a DailyMacros instance
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
        self.protein = dictionary["protein"] as? Double
        self.carbs = dictionary["carbs"] as? Double
        self.fat = dictionary["fat"] as? Double
        self.calories = dictionary["calories"] as? Double
    }
    
    // Converts the DailyMacros instance into a dictionary
    var dictionary: [String: Any] {
        var result: [String: Any] = [
            "id": id.uuidString,
            "date": date.timeIntervalSince1970
        ]
        
        // Add optional values only if they are not nil
        if let protein { result["protein"] = protein }
        if let carbs { result["carbs"] = carbs }
        if let fat { result["fat"] = fat }
        if let calories { result["calories"] = calories }
        
        return result
    }
}
