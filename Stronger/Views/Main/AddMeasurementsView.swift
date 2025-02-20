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
    
    @State private var showWeightConfirmation = false
    @State private var showMacroConfirmation = false
    @State private var showBodyMeasurementsConfirmation = false
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    Text("Weight")
                        .font(.title2).bold()
                        .foregroundColor(Color.theme.text)
                    
                    CustomTextField(placeholder: "Weight",
                                    text: $weightViewModel.weight,
                                    keyboardType: .decimalPad)
                    
                    Button("Save Weight", action: saveWeight)
                        .buttonStyle(CustomButtonStyle())
                        .disabled(weightViewModel.weight.isEmpty)
                        .opacity(weightViewModel.weight.isEmpty ? 0.5 : 1.0)
                    
                    Divider().padding(.vertical, 10)
                    
                    Text("Macros")
                        .font(.title2).bold()
                        .foregroundColor(Color.theme.text)
                    
                    CustomTextField(placeholder: "Protein (g)", text: $macrosViewModel.protein, keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Carbs (g)", text: $macrosViewModel.carbs, keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Fat (g)", text: $macrosViewModel.fat, keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Calories", text: $macrosViewModel.calories, keyboardType: .decimalPad)
                    
                    Button("Save Macros", action: saveMacros)
                        .buttonStyle(CustomButtonStyle())
                        .disabled([macrosViewModel.protein, macrosViewModel.carbs, macrosViewModel.fat, macrosViewModel.calories].contains(where: \.isEmpty))
                        .opacity([macrosViewModel.protein, macrosViewModel.carbs, macrosViewModel.fat, macrosViewModel.calories].contains(where: \.isEmpty) ? 0.5 : 1.0)
                    
                    Divider().padding(.vertical, 10)
                    
                    Text("Body Measurements")
                        .font(.title2).bold()
                        .foregroundColor(Color.theme.text)
                    
                    CustomTextField(placeholder: "Chest (cm)", text: $bodyMeasurementsViewModel.chest, keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Shoulders (cm)", text: $bodyMeasurementsViewModel.shoulders, keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Waist (cm)", text: $bodyMeasurementsViewModel.waist, keyboardType: .decimalPad)
                    CustomTextField(placeholder: "Hips (cm)", text: $bodyMeasurementsViewModel.hips, keyboardType: .decimalPad)
                    
                    Button("Save Measurements", action: saveBodyMeasurements)
                        .buttonStyle(CustomButtonStyle())
                        .disabled([bodyMeasurementsViewModel.chest, bodyMeasurementsViewModel.shoulders, bodyMeasurementsViewModel.waist, bodyMeasurementsViewModel.hips].contains(where: \.isEmpty))
                        .opacity([bodyMeasurementsViewModel.chest, bodyMeasurementsViewModel.shoulders, bodyMeasurementsViewModel.waist, bodyMeasurementsViewModel.hips].contains(where: \.isEmpty) ? 0.5 : 1.0)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage).foregroundColor(.red)
                    } else if showWeightConfirmation {
                        Text("Weight saved!").foregroundColor(.green)
                    } else if showMacroConfirmation {
                        Text("Macros saved!").foregroundColor(.green)
                    } else if showBodyMeasurementsConfirmation {
                        Text("Measurements saved!").foregroundColor(.green)
                    }
                    
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
    }
    
    private func saveWeight() {
        weightViewModel.saveWeight { result in
            switch result {
            case .success():
                showWeightConfirmation = true
                errorMessage = nil
                weightViewModel.clearWeightField()
            case .failure(let error):
                showWeightConfirmation = false
                errorMessage = error.localizedDescription
                print("Error saving weight: \(error)")
            }
        }
    }
    
    private func saveMacros() {
        macrosViewModel.saveMacros { result in
            switch result {
            case .success():
                showMacroConfirmation = true
                errorMessage = nil
                macrosViewModel.clearMacrosFields()
            case .failure(let error):
                showMacroConfirmation = false
                errorMessage = error.localizedDescription
                print("Error saving macros: \(error)")
            }
        }
    }
    
    private func saveBodyMeasurements() {
        bodyMeasurementsViewModel.saveMeasurements { result in
            switch result {
            case .success():
                showBodyMeasurementsConfirmation = true
                errorMessage = nil
                bodyMeasurementsViewModel.clearMeasurementsFields()
            case .failure(let error):
                showBodyMeasurementsConfirmation = false
                errorMessage = error.localizedDescription
                print("Error saving measurements: \(error)")
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
