//
//  ExerciseField.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 21/10/2024.
//

import SwiftUI

struct ExerciseField: View {
    let label: String
    @Binding var value: String
    
    var body: some View {
        HStack {
            Text("\(label):")
                .font(.subheadline)
                .foregroundColor(.gray)
                .frame(width: 55, alignment: .leading)
            
            Spacer()
            
            TextField(label, text: $value)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 50, maxWidth: .infinity)
        }
    }
}

#Preview {
    ExerciseField(label: "Weight", value: .constant("10"))
}
