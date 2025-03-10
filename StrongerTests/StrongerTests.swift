////
////  StrongerTests.swift
////  StrongerTests
////
////  Created by Liza on 02/01/2025.
////
//
//import XCTest
//@testable import Stronger
//
//final class StrongerTests: XCTestCase {
//
//    func testMoveDay_Left() {
//        let viewModel = WorkoutViewModel()
//        viewModel.isTesting = true
//        viewModel.workoutDays = [
//            WorkoutDay(dayName: "Monday", exercises: [], order: 0),
//            WorkoutDay(dayName: "Tuesday", exercises: [], order: 1),
//            WorkoutDay(dayName: "Wednesday", exercises: [], order: 2)
//        ]
//
//        viewModel.moveDay(fromIndex: 1, directionLeft: true)
//
//        XCTAssertEqual(viewModel.workoutDays[0].dayName, "Tuesday")
//        XCTAssertEqual(viewModel.workoutDays[1].dayName, "Monday")
//        XCTAssertEqual(viewModel.workoutDays[2].dayName, "Wednesday")
//    }
//
//    func testMoveDay_Right() {
//        let viewModel = WorkoutViewModel()
//        viewModel.isTesting = true
//        viewModel.workoutDays = [
//            WorkoutDay(dayName: "Monday", exercises: [], order: 0),
//            WorkoutDay(dayName: "Tuesday", exercises: [], order: 1),
//            WorkoutDay(dayName: "Wednesday", exercises: [], order: 2)
//        ]
//
//        viewModel.moveDay(fromIndex: 1, directionLeft: false)
//
//        XCTAssertEqual(viewModel.workoutDays[0].dayName, "Monday")
//        XCTAssertEqual(viewModel.workoutDays[1].dayName, "Wednesday")
//        XCTAssertEqual(viewModel.workoutDays[2].dayName, "Tuesday")
//    }
//
//    func testMoveDay_OutOfBounds() {
//        let viewModel = WorkoutViewModel()
//        viewModel.isTesting = true
//        viewModel.workoutDays = [
//            WorkoutDay(dayName: "Monday", exercises: [], order: 0)
//        ]
//
//        viewModel.moveDay(fromIndex: 0, directionLeft: true)
//
//        XCTAssertEqual(viewModel.workoutDays[0].dayName, "Monday")
//        XCTAssertEqual(viewModel.workoutDays.count, 1)
//    }
//}
//
//final class HydrationDataTests: XCTestCase {
//
//    func testHydrationDefaultValues() {
//        let hydrationData = HydrationData()
//        
//        XCTAssertEqual(hydrationData.drinks.count, 0)
//        XCTAssertEqual(hydrationData.glassVolume, 0.25)
//        XCTAssertEqual(hydrationData.dailyLimit, 2.0)
//    }
//
//    func testAddDrink() {
//        var hydrationData = HydrationData()
//        hydrationData.drinks.append(0.25)
//        
//        XCTAssertEqual(hydrationData.drinks.count, 1)
//        XCTAssertEqual(hydrationData.drinks.first, 0.25)
//    }
//
//    func testRemoveDrink() {
//        var hydrationData = HydrationData()
//        hydrationData.drinks = [0.25, 0.5]
//        hydrationData.drinks.removeLast()
//        
//        XCTAssertEqual(hydrationData.drinks.count, 1)
//        XCTAssertEqual(hydrationData.drinks.first, 0.25)
//    }
//
//    func testResetDrinks() {
//        var hydrationData = HydrationData()
//        hydrationData.drinks = [0.25, 0.5, 0.75]
//        hydrationData.drinks.removeAll()
//        
//        XCTAssertTrue(hydrationData.drinks.isEmpty)
//    }
//
//    func testProgressCalculation() {
//        var hydrationData = HydrationData()
//        hydrationData.dailyLimit = 2.0
//        hydrationData.drinks = [0.5, 0.5]
//
//        let progress = hydrationData.drinks.reduce(0, +) / hydrationData.dailyLimit
//
//        XCTAssertEqual(progress, 0.5)
//    }
//}
