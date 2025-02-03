//
//  BodyMeasurements.swift
//  Stronger
//
//  Created by Liza on 03/02/2025.
//

import Foundation

struct BodyMeasurements: Identifiable {
    let id: UUID
    let date: Date
    let chest: Double?
    let shoulders: Double?
    let waist: Double?
    let hips: Double?
    
    init(
        id: UUID = UUID(),
        date: Date,
        chest: Double?,
        shoulders: Double?,
        waist: Double?,
        hips: Double?
    ) {
        self.id = id
        self.date = date
        self.chest = chest
        self.shoulders = shoulders
        self.waist = waist
        self.hips = hips
    }
}

extension BodyMeasurements {
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
        self.chest = dictionary["chest"] as? Double
        self.shoulders = dictionary["shoulders"] as? Double
        self.waist = dictionary["waist"] as? Double
        self.hips = dictionary["hips"] as? Double
    }
    
    var dictionary: [String: Any] {
        var result: [String: Any] = [
            "id": id.uuidString,
            "date": date.timeIntervalSince1970
        ]
        
        if let chest = chest { result["chest"] = chest }
        if let shoulders = shoulders { result["shoulders"] = shoulders }
        if let waist = waist { result["waist"] = waist }
        if let hips = hips { result["hips"] = hips }
        
        return result
    }
}
