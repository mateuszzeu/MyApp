//
//  AddMeasurementsView.swift
//  Stronger
//
//  Created by Liza on 22/01/2025.
//

import SwiftUI

struct AddMeasurementsView: View {
    @ObservedObject var viewModel: MeasurementsViewModel
    
    @State private var showConfirmation = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color.clear
                .applyGradientBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                TextField("Weight (kg)", text: $viewModel.weight)
                    .keyboardType(.decimalPad)
                    .padding()
                    .applyTransparentBackground()
                
                TextField("Protein (g)", text: $viewModel.protein)
                    .keyboardType(.decimalPad)
                    .padding()
                    .applyTransparentBackground()
                
                TextField("Carbs (g)", text: $viewModel.carbs)
                    .keyboardType(.decimalPad)
                    .padding()
                    .applyTransparentBackground()
                
                TextField("Fat (g)", text: $viewModel.fat)
                    .keyboardType(.decimalPad)
                    .padding()
                    .applyTransparentBackground()
                
                TextField("Calories", text: $viewModel.calories)
                    .keyboardType(.decimalPad)
                    .padding()
                    .applyTransparentBackground()
                
                Button(action: {
                    saveMeasurement()
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(Color.theme.text)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.theme.primary)
                        .cornerRadius(10)
                }
                .disabled([viewModel.weight,
                           viewModel.protein,
                           viewModel.carbs,
                           viewModel.fat,
                           viewModel.calories].contains(where: \.isEmpty))
                .opacity([viewModel.weight,
                          viewModel.protein,
                          viewModel.carbs,
                          viewModel.fat,
                          viewModel.calories].contains(where: \.isEmpty) ? 0.5 : 1.0)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else if showConfirmation {
                    Text("Measurement saved!")
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
            .padding()
            .padding(.top, 66)
        }
        
    }
    
    private func saveMeasurement() {
        viewModel.commitMeasurement { result in
            switch result {
            case .success():
                showConfirmation = true
                errorMessage = nil
                viewModel.clearFields()
            case .failure(let error):
                showConfirmation = false
                errorMessage = error.localizedDescription
                print("Error saving measurement: \(error)")
            }
        }
    }
}

#Preview {
    let viewModel = MeasurementsViewModel()
    viewModel.weight = "70"
    viewModel.protein = "150"
    viewModel.carbs = "200"
    viewModel.fat = "50"
    viewModel.calories = "2500"
    
    return AddMeasurementsView(viewModel: viewModel)
}
