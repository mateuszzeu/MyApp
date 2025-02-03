//
//  WeightHistoryView.swift
//  Stronger
//
//  Created by Liza on 03/02/2025.
//

import SwiftUI

struct WeightHistoryView: View {
    @ObservedObject var weightViewModel: WeightViewModel
    
    var body: some View {
        VStack {
            Text("Weight History")
                .font(.title2).bold()
                .foregroundColor(Color.theme.text)
                .padding(.top, 10)
            
            if weightViewModel.dailyWeights.isEmpty {
                Text("No weight records yet.")
                    .padding()
                    .foregroundColor(Color.theme.text.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(weightViewModel.dailyWeights) { weightEntry in
                    VStack {
                        Text("\(weightEntry.date.formatted(date: .abbreviated, time: .omitted))")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        if let weight = weightEntry.weight {
                            Text("Weight: \(String(format: "%.1f", weight)) kg")
                                .font(.subheadline)
                                .foregroundColor(Color.theme.text.opacity(0.7))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                    .background(Color.theme.primary.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
}
