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
        // Arrange
        let viewModel = WorkoutViewModel()
        viewModel.isTesting = true
        viewModel.workoutDays = [
            WorkoutDay(dayName: "Poniedziałek", exercises: [], order: 0),
            WorkoutDay(dayName: "Wtorek", exercises: [], order: 1),
            WorkoutDay(dayName: "Środa", exercises: [], order: 2)
        ]

        // Act
        viewModel.moveDay(fromIndex: 1, directionLeft: true)

        // Assert
        XCTAssertEqual(viewModel.workoutDays[0].dayName, "Wtorek", "Wtorek powinien być na miejscu Poniedziałku")
        XCTAssertEqual(viewModel.workoutDays[1].dayName, "Poniedziałek", "Poniedziałek powinien być na miejscu Wtorku")
        XCTAssertEqual(viewModel.workoutDays[2].dayName, "Środa", "Środa powinna pozostać na swoim miejscu")

        // Assert
        XCTAssertEqual(viewModel.workoutDays[0].order, 0, "Order pierwszego dnia powinien wynosić 0")
        XCTAssertEqual(viewModel.workoutDays[1].order, 1, "Order drugiego dnia powinien wynosić 1")
        XCTAssertEqual(viewModel.workoutDays[2].order, 2, "Order trzeciego dnia powinien wynosić 2")
    }

    func testMoveDay_Right() {
        // Arrange:
        let viewModel = WorkoutViewModel()
        viewModel.isTesting = true
        viewModel.workoutDays = [
            WorkoutDay(dayName: "Poniedziałek", exercises: [], order: 0),
            WorkoutDay(dayName: "Wtorek", exercises: [], order: 1),
            WorkoutDay(dayName: "Środa", exercises: [], order: 2)
        ]

        // Act
        viewModel.moveDay(fromIndex: 1, directionLeft: false)

        // Assert
        XCTAssertEqual(viewModel.workoutDays[0].dayName, "Poniedziałek", "Poniedziałek powinien pozostać na swoim miejscu")
        XCTAssertEqual(viewModel.workoutDays[1].dayName, "Środa", "Środa powinna być na miejscu Wtorku")
        XCTAssertEqual(viewModel.workoutDays[2].dayName, "Wtorek", "Wtorek powinien być na miejscu Środy")

        // Assert
        XCTAssertEqual(viewModel.workoutDays[0].order, 0, "Order pierwszego dnia powinien wynosić 0")
        XCTAssertEqual(viewModel.workoutDays[1].order, 1, "Order drugiego dnia powinien wynosić 1")
        XCTAssertEqual(viewModel.workoutDays[2].order, 2, "Order trzeciego dnia powinien wynosić 2")
    }

    func testMoveDay_OutOfBounds() {
        // Arrange
        let viewModel = WorkoutViewModel()
        viewModel.isTesting = true 
        viewModel.workoutDays = [
            WorkoutDay(dayName: "Poniedziałek", exercises: [], order: 0)
        ]

        // Act
        viewModel.moveDay(fromIndex: 0, directionLeft: true)

        // Assert
        XCTAssertEqual(viewModel.workoutDays[0].dayName, "Poniedziałek", "Poniedziałek powinien pozostać na swoim miejscu")
        XCTAssertEqual(viewModel.workoutDays.count, 1, "Powinna być tylko jedna pozycja w tablicy")
    }
}


final class HydrationDataTests: XCTestCase {

    func testHydrationDefaultValues() {
        // Arrange
        var hydrationData = HydrationData()
        
        // Assert
        XCTAssertEqual(hydrationData.glassCount, 0, "Domyślna liczba szklanek powinna wynosić 0")
        XCTAssertEqual(hydrationData.glassVolume, 0.25, "Domyślna objętość szklanki powinna wynosić 0.25 litra")
        XCTAssertEqual(hydrationData.dailyLimit, 2.0, "Domyślny dzienny limit powinien wynosić 2.0 litra")
    }

    func testHydrationUpdateGlassCount() {
        // Arrange
        var hydrationData = HydrationData()
        
        // Act
        hydrationData.glassCount += 1
        hydrationData.glassCount += 1
        hydrationData.glassCount -= 1
        
        // Assert
        XCTAssertEqual(hydrationData.glassCount, 1, "Liczba szklanek powinna wynosić 1 po dodaniu i odjęciu")
    }

    func testHydrationLimitUpdate() {
        // Arrange
        var hydrationData = HydrationData()
        
        // Act
        hydrationData.dailyLimit = 3.0
        hydrationData.glassVolume = 0.5
        
        // Assert
        XCTAssertEqual(hydrationData.dailyLimit, 3.0, "Dzienny limit powinien wynosić 3.0 litra po aktualizacji")
        XCTAssertEqual(hydrationData.glassVolume, 0.5, "Objętość szklanki powinna wynosić 0.5 litra po aktualizacji")
    }

    func testHydrationProgressCalculation() {
        // Arrange
        var hydrationData = HydrationData()
        hydrationData.dailyLimit = 2.0
        hydrationData.glassVolume = 0.5
        
        // Act
        hydrationData.glassCount = 2
        let progress = CGFloat(hydrationData.glassCount) * hydrationData.glassVolume / hydrationData.dailyLimit
        
        // Assert
        XCTAssertEqual(progress, 0.5, "Postęp powinien wynosić 50% przy dwóch szklankach o objętości 0.5 litra i limicie 2.0 litra")
    }
}
