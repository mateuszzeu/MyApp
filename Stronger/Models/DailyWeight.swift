//
//  DailyWeight.swift
//  Stronger
//
//  Created by Liza on 03/02/2025.
//

import Foundation

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

extension DailyWeight {
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
        
        self.id = uuid
        self.date = dateValue
        self.weight = weightValue
    }
    
    var dictionary: [String: Any] {
        var result: [String: Any] = [
            "id": id.uuidString,
            "date": date.timeIntervalSince1970
        ]
        
        if let weight = weight {
            result["weight"] = weight
        }
        
        return result
    }
}
