//
//  InfoView.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 23/10/2024.
//

import SwiftUI
import PhotosUI

struct InfoView: View {
    @State var exercise: Exercise
    @ObservedObject var viewModel: WorkoutViewModel
    var dayName: String
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?

    var body: some View {
        VStack {
            GeometryReader { geometry in
                TextEditor(text: Binding(
                    get: { exercise.info },
                    set: { newValue in
                        exercise.info = newValue
                        viewModel.updateExercise(dayName: dayName, exercise: exercise)
                    }
                ))
                .applyTransparentBackground()
                .padding()
                .frame(height: geometry.size.height * 0.6)
            }

            if let imageURL = exercise.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding()
                } placeholder: {
                    ProgressView()
                        .frame(height: 200)
                }
            } else if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            }

            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                Text("Select Image")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding()
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                        print("✅ Image selected successfully!")

                        viewModel.uploadExerciseImage(dayName: dayName, exerciseId: exercise.id, imageData: data) { result in
                            switch result {
                            case .success(let imageURL):
                                print("✅ Image URL: \(imageURL)")
                                exercise.imageURL = imageURL
                                viewModel.updateExercise(dayName: dayName, exercise: exercise)
                            case .failure(let error):
                                print("❌ Upload failed: \(error.localizedDescription)")
                            }
                        }
                    } else {
                        print("❌ Failed to load image data")
                    }
                }
            }

        }
        .applyGradientBackground()
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.theme.text)
                }
            }
        }
    }
}

#Preview {
    InfoView(exercise: Exercise(name: "Squat", sets: "3", reps: "10", weight: "100", info: "Sample info"), viewModel: WorkoutViewModel(), dayName: "Push")
}
