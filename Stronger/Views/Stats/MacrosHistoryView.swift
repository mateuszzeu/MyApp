//
//  MacrosHistoryView.swift
//  Stronger
//
//  Created by Liza on 03/02/2025.
//

import SwiftUI

struct MacrosHistoryView: View {
    @ObservedObject var macrosViewModel: MacrosViewModel
    
    var body: some View {
        VStack {
            Text("Macros History")
                .font(.title2).bold()
                .foregroundColor(Color.theme.text)
                .padding(.top, 10)

            if macrosViewModel.dailyMacros.isEmpty {
                Text("No macros records yet.")
                    .padding()
                    .foregroundColor(Color.theme.text.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(macrosViewModel.dailyMacros, id: \.id) { macrosEntry in
                    VStack {
                        Text("\(macrosEntry.date.formatted(date: .abbreviated, time: .omitted))")
                            .font(.headline)
                            .foregroundColor(Color.theme.text)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Calories: \(Int(macrosEntry.calories ?? 0)) kcal")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.text.opacity(0.7))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Protein: \(Int(macrosEntry.protein ?? 0)) g, Carbs: \(Int(macrosEntry.carbs ?? 0)) g, Fat: \(Int(macrosEntry.fat ?? 0)) g")
                            .font(.footnote)
                            .foregroundColor(Color.theme.text.opacity(0.6))
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
    let macrosViewModel = MacrosViewModel()
    
    macrosViewModel.dailyMacros = [
        DailyMacros(date: Date(), protein: 150, carbs: 200, fat: 50, calories: 2500),
        DailyMacros(date: Date().addingTimeInterval(-86400), protein: 140, carbs: 210, fat: 55, calories: 2600)
    ]
    
    return MacrosHistoryView(macrosViewModel: macrosViewModel)
}
