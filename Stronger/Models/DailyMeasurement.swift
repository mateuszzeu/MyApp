//
//  DailyMeasurement.swift
//  Stronger
//
//  Created by Liza on 22/01/2025.
//

import Foundation

struct DailyMeasurement: Identifiable {
    
    struct Macros {
        let protein: Double
        let carbs: Double
        let fat: Double
        let calories: Double
    }

    let id: UUID
    let date: Date
    let weight: Double?
    let macros: Macros?
    
    init(
        id: UUID = UUID(),
        date: Date,
        weight: Double?,
        macros: Macros?
    ) {
        self.id = id
        self.date = date
        self.weight = weight
        self.macros = macros
    }
}

extension DailyMeasurement {
    init?(dictionary: [String: Any]) {
        guard
            let idString = dictionary["id"] as? String,
            let uuid = UUID(uuidString: idString),
            let dateTimestamp = dictionary["date"] as? Double
        else {
            return nil
        }
        
        let dateValue = Date(timeIntervalSince1970: dateTimestamp)
        let weightValue = dictionary["weight"] as? Double
        
        let macrosStruct: Macros? = {
            if let macrosDict = dictionary["macros"] as? [String: Any],
               let protein = macrosDict["protein"] as? Double,
               let carbs = macrosDict["carbs"] as? Double,
               let fat = macrosDict["fat"] as? Double,
               let calories = macrosDict["calories"] as? Double {
                return Macros(protein: protein, carbs: carbs, fat: fat, calories: calories)
            }
            return nil
        }()
        
        self.id = uuid
        self.date = dateValue
        self.weight = weightValue
        self.macros = macrosStruct
    }
    
    var dictionary: [String: Any] {
        var result: [String: Any] = [
            "id": id.uuidString,
            "date": date.timeIntervalSince1970
        ]
        
        if let weight = weight {
            result["weight"] = weight
        }
        
        if let macros = macros {
            result["macros"] = [
                "protein": macros.protein,
                "carbs": macros.carbs,
                "fat": macros.fat,
                "calories": macros.calories
            ]
        }
        
        return result
    }
}
