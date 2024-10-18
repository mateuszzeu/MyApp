//
//  WorkoutViewModel.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 18/10/2024.
//

import SwiftUI
import Combine

class WorkoutViewModel: ObservableObject {
    @Published var workoutDays: [WorkoutDay] = []
    
//    init() {
//        // W przyszłości tutaj będzie logika połączenia z Firebase, pobieranie danych
//        // loadWorkouts()
//    }
//    
//    private func loadWorkout() {
//        // Logika pobierania danych z Firebase
//        // zastepcza:
//        self.workoutDays = [
//            WorkoutDay(dayName: "Pull", exercises: [
//                Exercise(name: "Pull-up", sets: "3/3", reps: "10/12", weight: "30", info: "Focus on form")
//            ])
//        ]
//    }
}
