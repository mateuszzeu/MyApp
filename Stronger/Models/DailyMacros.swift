//
//  DailyMacros.swift
//  Stronger
//
//  Created by Liza on 22/01/2025.
//

import Foundation

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

extension DailyMacros {
    init?(dictionary: [String: Any]) {
        guard
            let idString = dictionary["id"] as? String,
            let uuid = UUID(uuidString: idString),
            let dateTimestamp = dictionary["date"] as? Double
        else {
            return nil
        }
        
        let dateValue = Date(timeIntervalSince1970: dateTimestamp)
        
        self.id = uuid
        self.date = dateValue
        self.protein = dictionary["protein"] as? Double
        self.carbs = dictionary["carbs"] as? Double
        self.fat = dictionary["fat"] as? Double
        self.calories = dictionary["calories"] as? Double
    }
    
    var dictionary: [String: Any] {
        var result: [String: Any] = [
            "id": id.uuidString,
            "date": date.timeIntervalSince1970
        ]
        
        if let protein = protein { result["protein"] = protein }
        if let carbs = carbs { result["carbs"] = carbs }
        if let fat = fat { result["fat"] = fat }
        if let calories = calories { result["calories"] = calories }
        
        return result
    }
}
