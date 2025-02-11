//
//  Exercise.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 18/10/2024.
//

import Foundation

struct Exercise: Identifiable, Equatable {
    var id: UUID
    var name: String
    var sets: String
    var reps: String
    var weight: String
    var info: String
    var imageURLs: [String]?
    
    init(
        id: UUID = UUID(),
        name: String,
        sets: String,
        reps: String,
        weight: String,
        info: String,
        imageURLs: [String]? = nil
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.info = info
        self.imageURLs = imageURLs
    }
}

extension Exercise {
    
    init?(dictionary: [String: Any]) {
        guard
            let idString = dictionary["id"] as? String,
            let uuid = UUID(uuidString: idString),
            let name = dictionary["name"] as? String,
            let sets = dictionary["sets"] as? String,
            let reps = dictionary["reps"] as? String,
            let weight = dictionary["weight"] as? String,
            let info = dictionary["info"] as? String
        else {
            return nil
        }
        
        self.id = uuid
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.info = info
        self.imageURLs = dictionary["imageURLs"] as? [String]
    }
    
    var dictionary: [String: Any] {
            var dict: [String: Any] = [
                "id": id.uuidString,
                "name": name,
                "sets": sets,
                "reps": reps,
                "weight": weight,
                "info": info
            ]
            if let imageURLs = imageURLs {
                dict["imageURLs"] = imageURLs
            }
            return dict
        }
}
