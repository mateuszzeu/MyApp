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
                .padding(.horizontal)
            }

            if let imageURLs = exercise.imageURLs, !imageURLs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(imageURLs, id: \.self) { imageURL in
                            if let url = URL(string: imageURL) {
                                ZStack(alignment: .topTrailing) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .frame(height: 180)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(infoViewModel.selectedImagesForDeletion.contains(imageURL) ? Color.red : Color.clear, lineWidth: 3)
                                            )
                                            .padding(4)
                                            .onTapGesture {
                                                infoViewModel.toggleImageSelection(imageURL)
                                            }
                                    } placeholder: {
                                        ProgressView()
                                            .frame(height: 180)
                                    }

                                    if infoViewModel.selectedImagesForDeletion.contains(imageURL) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.red)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .padding(6)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            if !infoViewModel.selectedImagesForDeletion.isEmpty {
                Button(action: {
                    showConfirmationAlert = true
                }) {
                    Text("Delete Selected (\(infoViewModel.selectedImagesForDeletion.count))")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(Color.red.opacity(0.85))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .alert(isPresented: $showConfirmationAlert) {
                    Alert(
                        title: Text("Confirm Deletion"),
                        message: Text("Are you sure you want to delete these images?"),
                        primaryButton: .destructive(Text("Delete")) {
                            infoViewModel.deleteSelectedImages(dayName: dayName, exerciseId: exercise.id, workoutViewModel: viewModel) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success(let deletedImages):
                                        exercise.imageURLs?.removeAll { deletedImages.contains($0) }
                                    case .failure(let error):
                                        ErrorHandler.shared.handle(error)
                                    }
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }

            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                Text("Add Image")
                    .font(.subheadline)
                    .foregroundColor(Color.theme.text)
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color.theme.primary.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
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
        .onTapGesture {
            hideKeyboard()
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
