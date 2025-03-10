//
//  AddMeasurementsView.swift
//  Stronger
//
//  Created by Liza on 22/01/2025.
//

import SwiftUI

struct AddMeasurementsView: View {
    @ObservedObject var weightViewModel: WeightViewModel
    @ObservedObject var macrosViewModel: MacrosViewModel
    @ObservedObject var bodyMeasurementsViewModel: BodyMeasurementsViewModel

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: - Weight
                    Text("Weight")
                        .font(.title2).bold()
                        .foregroundColor(Color.theme.text)

                    CustomTextField(
                        placeholder: "Weight",
                        text: $weightViewModel.weight,
                        keyboardType: .decimalPad
                    )

                    Button {
                        saveWeight()
                    } label: {
                        Text("Save Weight")
                    }
                    .buttonStyle(CustomButtonStyle())
                    .disabled(weightViewModel.weight.isEmpty)
                    .opacity(weightViewModel.weight.isEmpty ? 0.5 : 1)

                    Divider().padding(.vertical, 10)

                    // MARK: - Macros
                    Text("Macros")
                        .font(.title2).bold()
                        .foregroundColor(Color.theme.text)

                    CustomTextField(placeholder: "Protein (g)",
                                    text: $macrosViewModel.protein,
                                    keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Carbs (g)",
                                    text: $macrosViewModel.carbs,
                                    keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Fat (g)",
                                    text: $macrosViewModel.fat,
                                    keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Calories",
                                    text: $macrosViewModel.calories,
                                    keyboardType: .decimalPad)

                    Button {
                        saveMacros()
                    } label: {
                        Text("Save Macros")
                    }
                    .buttonStyle(CustomButtonStyle())
                    .disabled([macrosViewModel.protein,
                               macrosViewModel.carbs,
                               macrosViewModel.fat,
                               macrosViewModel.calories]
                               .contains(where: \.isEmpty))
                    .opacity([macrosViewModel.protein,
                              macrosViewModel.carbs,
                              macrosViewModel.fat,
                              macrosViewModel.calories]
                              .contains(where: \.isEmpty) ? 0.5 : 1.0)

                    Divider().padding(.vertical, 10)

                    // MARK: - Body Measurements
                    Text("Body Measurements")
                        .font(.title2).bold()
                        .foregroundColor(Color.theme.text)

                    CustomTextField(placeholder: "Chest (cm)",
                                    text: $bodyMeasurementsViewModel.chest,
                                    keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Shoulders (cm)",
                                    text: $bodyMeasurementsViewModel.shoulders,
                                    keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Waist (cm)",
                                    text: $bodyMeasurementsViewModel.waist,
                                    keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Hips (cm)",
                                    text: $bodyMeasurementsViewModel.hips,
                                    keyboardType: .decimalPad)

                    Button {
                        saveBodyMeasurements()
                    } label: {
                        Text("Save Measurements")
                    }
                    .buttonStyle(CustomButtonStyle())
                    .disabled([bodyMeasurementsViewModel.chest,
                               bodyMeasurementsViewModel.shoulders,
                               bodyMeasurementsViewModel.waist,
                               bodyMeasurementsViewModel.hips]
                               .contains(where: \.isEmpty))
                    .opacity([bodyMeasurementsViewModel.chest,
                               bodyMeasurementsViewModel.shoulders,
                               bodyMeasurementsViewModel.waist,
                               bodyMeasurementsViewModel.hips]
                               .contains(where: \.isEmpty) ? 0.5 : 1.0)

                    Spacer()
                }
                .padding()
            }
            .padding(.top, 66)
            .safeAreaInset(edge: .bottom) {
                Spacer().frame(height: 120)
            }
        }
        .applyGradientBackground()
        .onTapGesture {
            hideKeyboard()
        }
        .overlay(
            ErrorBannerView()
                .padding(.top, 50),
            alignment: .top
        )
    }

    // MARK: - Private Functions

    private func saveWeight() {
        weightViewModel.saveWeight { result in
            switch result {
            case .success:
                weightViewModel.clearWeightField()
            case .failure(let error):
                ErrorHandler.shared.handle(error)
            }
        }
    }

    private func saveMacros() {
        macrosViewModel.saveMacros { result in
            switch result {
            case .success:
                macrosViewModel.clearMacrosFields()
            case .failure(let error):
                ErrorHandler.shared.handle(error)
            }
        }
    }

    private func saveBodyMeasurements() {
        bodyMeasurementsViewModel.saveMeasurements { result in
            switch result {
            case .success:
                bodyMeasurementsViewModel.clearMeasurementsFields()
            case .failure(let error):
                ErrorHandler.shared.handle(error)
            }
        }
    }
}

#Preview {
    let weightViewModel = WeightViewModel()
    let macrosViewModel = MacrosViewModel()
    let bodyMeasurementsViewModel = BodyMeasurementsViewModel()

    return AddMeasurementsView(
        weightViewModel: weightViewModel,
        macrosViewModel: macrosViewModel,
        bodyMeasurementsViewModel: bodyMeasurementsViewModel
    )
}
