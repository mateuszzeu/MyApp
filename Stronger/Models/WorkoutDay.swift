//
//  WorkoutDay.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 18/10/2024.
//

import Foundation

struct WorkoutDay: Identifiable {
    let id = UUID()
    var dayName: String
    var dateAdded: Date
    var exercises: [Exercise]
}
