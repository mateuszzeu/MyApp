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
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(viewModel.workoutDays, id: \.id) { day in
                    Text(day.dayName)
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(selectedDay == day.dayName ? Color.blue.opacity(0.2) : Color.clear)
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedDay = day.dayName
                        }
                        .foregroundColor(.black)
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
        }
        .padding(.horizontal)
    }
}

#Preview {
    WorkoutDaysScrollView(
        viewModel: WorkoutViewModel(),
        selectedDay: .constant("")
    )
}
