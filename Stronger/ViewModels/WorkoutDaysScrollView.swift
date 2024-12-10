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
                ForEach(viewModel.workoutDays) { day in
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
                }
            }
        }
        .padding(.horizontal)
    }
}
