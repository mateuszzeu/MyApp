//
//  CompletedWorkout.swift
//  Stronger
//
//  Created by Liza on 14/01/2025.
//

import Foundation

// MARK: - Model
struct CompletedWorkout: Identifiable {
    let id: UUID
    let date: Date
    let workoutDayName: String
    let exercises: [Exercise]
    let notes: String?
    
    init(
        id: UUID = UUID(),
        date: Date,
        workoutDayName: String,
        exercises: [Exercise],
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.workoutDayName = workoutDayName
        self.exercises = exercises
        self.notes = notes
    }
}

// MARK: - Dictionary Conversion
extension CompletedWorkout {
    
    // Converts a dictionary into a CompletedWorkout instance
    init?(dictionary: [String: Any]) {
        guard
            let idString = dictionary["id"] as? String,
            let uuid = UUID(uuidString: idString),
            let dateTimestamp = dictionary["date"] as? Double,
            let dayName = dictionary["workoutDayName"] as? String,
            let exercisesArray = dictionary["exercises"] as? [[String: Any]]
        else {
            return nil
        }

        self.id = uuid
        self.date = Date(timeIntervalSince1970: dateTimestamp)
        self.workoutDayName = dayName

        // Convert exercise dictionaries into Exercise objects
        self.exercises = exercisesArray.compactMap { Exercise(dictionary: $0) }
        
        self.notes = dictionary["notes"] as? String
    }
    
    // Converts the CompletedWorkout instance into a dictionary
    var dictionary: [String: Any] {
        return [
            "id": id.uuidString,
            "date": date.timeIntervalSince1970,
            "workoutDayName": workoutDayName,
            "exercises": exercises.map { $0.dictionary },
            "notes": notes ?? ""
        ]
    }
}
