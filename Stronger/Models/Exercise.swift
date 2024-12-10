//
//  Exercise.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 18/10/2024.
//

import Foundation

struct Exercise: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var sets: String
    var reps: String
    var weight: String
    var info: String
}
