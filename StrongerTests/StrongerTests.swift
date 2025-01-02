//
//  StrongerTests.swift
//  StrongerTests
//
//  Created by Liza on 02/01/2025.
//

import XCTest
@testable import Stronger

final class StrongerTests: XCTestCase {

    func testMoveDay_Left() {
        // Arrange: Przygotowanie modelu danych
        let viewModel = WorkoutViewModel()
        viewModel.isTesting = true
        viewModel.workoutDays = [
            WorkoutDay(dayName: "Poniedziałek", exercises: [], order: 0),
            WorkoutDay(dayName: "Wtorek", exercises: [], order: 1),
            WorkoutDay(dayName: "Środa", exercises: [], order: 2)
        ]

        // Act: Przesunięcie "Wtorek" w lewo (na miejsce "Poniedziałek")
        viewModel.moveDay(fromIndex: 1, directionLeft: true)

        // Assert: Sprawdzenie kolejności w tablicy
        XCTAssertEqual(viewModel.workoutDays[0].dayName, "Wtorek", "Wtorek powinien być na miejscu Poniedziałku")
        XCTAssertEqual(viewModel.workoutDays[1].dayName, "Poniedziałek", "Poniedziałek powinien być na miejscu Wtorku")
        XCTAssertEqual(viewModel.workoutDays[2].dayName, "Środa", "Środa powinna pozostać na swoim miejscu")

        // Assert: Sprawdzenie aktualizacji właściwości order
        XCTAssertEqual(viewModel.workoutDays[0].order, 0, "Order pierwszego dnia powinien wynosić 0")
        XCTAssertEqual(viewModel.workoutDays[1].order, 1, "Order drugiego dnia powinien wynosić 1")
        XCTAssertEqual(viewModel.workoutDays[2].order, 2, "Order trzeciego dnia powinien wynosić 2")
    }

    func testMoveDay_Right() {
        // Arrange: Przygotowanie modelu danych
        let viewModel = WorkoutViewModel()
        viewModel.isTesting = true
        viewModel.workoutDays = [
            WorkoutDay(dayName: "Poniedziałek", exercises: [], order: 0),
            WorkoutDay(dayName: "Wtorek", exercises: [], order: 1),
            WorkoutDay(dayName: "Środa", exercises: [], order: 2)
        ]

        // Act: Przesunięcie "Wtorek" w prawo (na miejsce "Środa")
        viewModel.moveDay(fromIndex: 1, directionLeft: false)

        // Assert: Sprawdzenie kolejności w tablicy
        XCTAssertEqual(viewModel.workoutDays[0].dayName, "Poniedziałek", "Poniedziałek powinien pozostać na swoim miejscu")
        XCTAssertEqual(viewModel.workoutDays[1].dayName, "Środa", "Środa powinna być na miejscu Wtorku")
        XCTAssertEqual(viewModel.workoutDays[2].dayName, "Wtorek", "Wtorek powinien być na miejscu Środy")

        // Assert: Sprawdzenie aktualizacji właściwości order
        XCTAssertEqual(viewModel.workoutDays[0].order, 0, "Order pierwszego dnia powinien wynosić 0")
        XCTAssertEqual(viewModel.workoutDays[1].order, 1, "Order drugiego dnia powinien wynosić 1")
        XCTAssertEqual(viewModel.workoutDays[2].order, 2, "Order trzeciego dnia powinien wynosić 2")
    }

    func testMoveDay_OutOfBounds() {
        // Arrange: Przygotowanie modelu danych
        let viewModel = WorkoutViewModel()
        viewModel.isTesting = true 
        viewModel.workoutDays = [
            WorkoutDay(dayName: "Poniedziałek", exercises: [], order: 0)
        ]

        // Act: Próba przesunięcia "Poniedziałek" w lewo (poza zakres)
        viewModel.moveDay(fromIndex: 0, directionLeft: true)

        // Assert: Sprawdzenie, czy tablica nie zmieniła się
        XCTAssertEqual(viewModel.workoutDays[0].dayName, "Poniedziałek", "Poniedziałek powinien pozostać na swoim miejscu")
        XCTAssertEqual(viewModel.workoutDays.count, 1, "Powinna być tylko jedna pozycja w tablicy")
    }
}

