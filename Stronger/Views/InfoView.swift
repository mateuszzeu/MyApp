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
    @ObservedObject var infoViewModel: InfoViewModel
    var dayName: String
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showConfirmationAlert = false

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

            if let imageURLs = exercise.imageURLs, !imageURLs.isEmpty {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(imageURLs, id: \.self) { imageURL in
                            if let url = URL(string: imageURL) {
                                ZStack(alignment: .topTrailing) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .frame(height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(infoViewModel.selectedImagesForDeletion.contains(imageURL) ? Color.red : Color.clear, lineWidth: 4)
                                            )
                                            .padding()
                                            .onTapGesture {
                                                infoViewModel.toggleImageSelection(imageURL)
                                            }
                                    } placeholder: {
                                        ProgressView()
                                            .frame(height: 200)
                                    }

                                    if infoViewModel.selectedImagesForDeletion.contains(imageURL) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.red)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .padding(8)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if !infoViewModel.selectedImagesForDeletion.isEmpty {
                Button(action: {
                    showConfirmationAlert = true
                }) {
                    Text("Delete Selected (\(infoViewModel.selectedImagesForDeletion.count))")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .alert(isPresented: $showConfirmationAlert) {
                    Alert(
                        title: Text("Confirm Deletion"),
                        message: Text("Are you sure you want to delete these images?"),
                        primaryButton: .destructive(Text("Delete")) {
                            infoViewModel.deleteSelectedImages(dayName: dayName, exerciseId: exercise.id, workoutViewModel: viewModel, exercise: exercise)
                        },
                        secondaryButton: .cancel()
                    )
                }
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
                guard let newItem = newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        selectedImageData = data
                        infoViewModel.uploadExerciseImage(dayName: dayName, exerciseId: exercise.id, imageData: data, workoutViewModel: viewModel) { result in
                            switch result {
                            case .success(let imageURL):
                                if exercise.imageURLs == nil {
                                    exercise.imageURLs = []
                                }
                                exercise.imageURLs?.append(imageURL)
                                viewModel.updateExercise(dayName: dayName, exercise: exercise)
                            case .failure(let error):
                                print("❌ Upload failed: \(error.localizedDescription)")
                            }
                        }
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
    InfoView(
        exercise: Exercise(name: "Squat", sets: "3", reps: "10", weight: "100", info: "Sample info", imageURLs: ["https://picsum.photos/400"]),
        viewModel: WorkoutViewModel(),
        infoViewModel: InfoViewModel(),
        dayName: "Push"
    )
}
