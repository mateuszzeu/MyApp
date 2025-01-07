//
//  WorkoutDaysScrollView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 10/12/2024.
//

import SwiftUI

struct WorkoutDaysScrollView: View {
    @ObservedObject var viewModel: WorkoutViewModel
    @Binding var selectedDay: String

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.workoutDays) { day in
                        Text(day.dayName)
                            .font(.system(size: 14, weight: .medium))
                            .lineLimit(1)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(selectedDay == day.dayName ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                            .onTapGesture {
                                selectedDay = day.dayName
                            }
                            .foregroundColor(Color.primary)
                            .contextMenu {
                                if let index = viewModel.workoutDays.firstIndex(where: { $0.id == day.id }) {
                                    if index > 0 {
                                        Button("Move Left") {
                                            viewModel.moveDay(fromIndex: index, directionLeft: true)
                                        }
                                    }
                                    if index < viewModel.workoutDays.count - 1 {
                                        Button("Move Right") {
                                            viewModel.moveDay(fromIndex: index, directionLeft: false)
                                        }
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal, 8)
            }
            .frame(height: 50)
        }
    }
}

#Preview {
    let viewModel = WorkoutViewModel()
    viewModel.workoutDays = [
        WorkoutDay(dayName: "Poniedziałek", exercises: [], order: 0),
        WorkoutDay(dayName: "Wtorek", exercises: [], order: 1),
        WorkoutDay(dayName: "Środa", exercises: [], order: 2),
        WorkoutDay(dayName: "Czwartek", exercises: [], order: 3),
        WorkoutDay(dayName: "Piątek", exercises: [], order: 4)
    ]
    return WorkoutDaysScrollView(viewModel: viewModel, selectedDay: .constant("Wtorek"))
}
