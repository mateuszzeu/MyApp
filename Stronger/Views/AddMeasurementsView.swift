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

            ScrollView {
                VStack(spacing: 20) {
                    CustomTextField(placeholder: "Weight (kg)", text: $viewModel.weight, keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Protein (g)", text: $viewModel.protein, keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Carbs (g)", text: $viewModel.carbs, keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Fat (g)", text: $viewModel.fat, keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Calories", text: $viewModel.calories, keyboardType: .decimalPad)

                    Button {
                        saveMeasurement()
                    } label: {
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
                        Text(errorMessage).foregroundColor(.red)
                    } else if showConfirmation {
                        Text("Measurement saved!").foregroundColor(.green)
                    }

                    Spacer()
                }
                .padding()
                .padding(.top, 66)
            }
            .scrollDismissesKeyboard(.interactively)
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
