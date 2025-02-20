//
//  BodyMeasurementsHistoryView.swift
//  Stronger
//
//  Created by Liza on 04/02/2025.
//

import SwiftUI

struct BodyMeasurementsHistoryView: View {
    @ObservedObject var bodyMeasurementsViewModel: BodyMeasurementsViewModel

    var body: some View {
        VStack {
            Text("Body Measurements History")
                .font(.title2).bold()
                .foregroundColor(Color.theme.text)
                .padding(.top, 10)

            if bodyMeasurementsViewModel.measurements.isEmpty {
                Text("No body measurements recorded yet.")
                    .padding()
                    .foregroundColor(Color.theme.text.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(bodyMeasurementsViewModel.measurements, id: \.id) { measurement in
                    VStack {
                        Text("\(measurement.date.formatted(date: .abbreviated, time: .omitted))")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Chest: \(Int(measurement.chest ?? 0)) cm, "
                             + "Shoulders: \(Int(measurement.shoulders ?? 0)) cm, "
                             + "Waist: \(Int(measurement.waist ?? 0)) cm, "
                             + "Hips: \(Int(measurement.hips ?? 0)) cm")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.text.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                    .background(Color.theme.primary.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
}


#Preview {
    let viewModel = BodyMeasurementsViewModel()
    
    viewModel.measurements = [
        BodyMeasurements(date: Date(), chest: 105, shoulders: 120, waist: 90, hips: 95),
        BodyMeasurements(date: Date().addingTimeInterval(-86400), chest: 106, shoulders: 121, waist: 91, hips: 96)
    ]
    
    return BodyMeasurementsHistoryView(bodyMeasurementsViewModel: viewModel)
}

