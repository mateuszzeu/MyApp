//
//  CompletedWorkout.swift
//  Stronger
//
//  Created by Liza on 14/01/2025.
//

import Foundation

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
    
    init?(dictionary: [String: Any]) {
        guard let dateTimestamp = dictionary["date"] as? Double else { return nil }
        let dateValue = Date(timeIntervalSince1970: dateTimestamp)
        
        guard let dayName = dictionary["workoutDayName"] as? String else { return nil }
        
        guard let exercisesArray = dictionary["exercises"] as? [[String: Any]] else { return nil }
        var parsedExercises: [Exercise] = []
        for exerciseDict in exercisesArray {
            if let ex = Exercise(dictionary: exerciseDict) {
                parsedExercises.append(ex)
            }
        }
        
        guard let idString = dictionary["id"] as? String,
              let uuid = UUID(uuidString: idString)
        else { return nil }
        
        let notes = dictionary["notes"] as? String
        
        self.id = uuid
        self.date = dateValue
        self.workoutDayName = dayName
        self.exercises = parsedExercises
        self.notes = notes
    }
    
    var dictionary: [String: Any] {
        let exercisesDictArray = exercises.map { $0.dictionary }
        
        return [
            "id": id.uuidString,
            "date": date.timeIntervalSince1970,
            "workoutDayName": workoutDayName,
            "exercises": exercisesDictArray,
            "notes": notes ?? ""
        ]
    }
}
