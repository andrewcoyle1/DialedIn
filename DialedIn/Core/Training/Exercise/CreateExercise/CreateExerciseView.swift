//
//  CreateExerciseView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import PhotosUI

struct CreateExerciseView: View {
    @Environment(DependencyContainer.self) private var container
    @Environment(\.dismiss) private var dismiss

    @State var viewModel: CreateExerciseViewModel
    
    var body: some View {
        NavigationStack {
            List {
                imageSection
                nameSection
                muscleGroupSection
                categorySection
            }
            .navigationBarTitle("New Custom Exercise")
            .navigationSubtitle("Define details and muscle groups")
            .navigationBarTitleDisplayMode(.large)
            .scrollIndicators(.hidden)
            .screenAppearAnalytics(name: "CreateExerciseView")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.onCancelPressed(onDismiss: { dismiss() })
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                #if DEBUG || MOCK
                ToolbarSpacer(.fixed, placement: .topBarLeading)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.showDebugView = true
                    } label: {
                        Image(systemName: "info")
                    }
                }
                #endif
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.onSavePressed(onDismiss: { dismiss() })
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!viewModel.canSave || viewModel.isSaving)
                }
            }
            .onChange(of: viewModel.selectedPhotoItem) {
                guard let newItem = viewModel.selectedPhotoItem else { return }
                Task {
                    await viewModel.onImageSelectorChanged(newItem)
                }
            }
            #if DEBUG || MOCK
            .sheet(isPresented: $viewModel.showDebugView) {
                DevSettingsView(
                    viewModel: DevSettingsViewModel(
                        interactor: CoreInteractor(
                            container: container
                        )
                    )
                )
            }
            #endif
            .showCustomAlert(alert: $viewModel.alert)
        }
    }

    private var imageSection: some View {
        Section {
            HStack {
                Spacer()
                Button {
                    viewModel.onImageSelectorPressed()
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.001))
                        Group {
                            if let data = viewModel.selectedImageData {
                                #if canImport(UIKit)
                                if let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                }
                                #elseif canImport(AppKit)
                                if let nsImage = NSImage(data: data) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .scaledToFill()
                                }
                                #endif
                            } else {
                                #if canImport(UIKit)
                                if let generatedImage = viewModel.generatedImage {
                                    Image(uiImage: generatedImage)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "dumbbell.fill")
                                        .font(.system(size: 120))
                                        .foregroundStyle(.accent)
                                }
                                #elseif canImport(AppKit)
                                Image(systemName: "dumbbell.fill")
                                    .font(.system(size: 120))
                                    .foregroundStyle(.accent)
                                #endif
                            }
                        }
                    }
                    .frame(width: 120, height: 120)
                }
                .photosPicker(isPresented: $viewModel.isImagePickerPresented, selection: $viewModel.selectedPhotoItem, matching: .images)
                Spacer()
            }
        } header: {
            HStack {
                Text("Exercise Image")
                Spacer()
                Button {
                    viewModel.onGenerateImagePressed()
                } label: {
                    Image(systemName: "wand.and.sparkles")
                        .font(.system(size: 20))
                }
                .disabled(viewModel.isGenerating || (viewModel.exerciseName?.isEmpty ?? true))
            }
        }
        .removeListRowFormatting()
    }

    private var nameSection: some View {
        Section {
            TextField("Add name", text: Binding(
                get: { viewModel.exerciseName ?? "" },
                set: { newValue in
                    viewModel.exerciseName = newValue.isEmpty ? nil : newValue
                }
            ))
            TextField("Add description", text: Binding(
                get: { viewModel.exerciseDescription ?? "" },
                set: { newValue in
                    viewModel.exerciseDescription = newValue.isEmpty ? nil : newValue
                }
            ))
        } header: {
            Text("Name")
        }
    }
    
    private var muscleGroupSection: some View {
        Section {
            ForEach(MuscleGroup.allCases.filter { $0 != .none }, id: \.self) { group in
                MultipleSelectionRow(
                    title: group.description,
                    isSelected: viewModel.muscleGroups.contains(group)
                ) {
                    if viewModel.muscleGroups.contains(group) {
                        viewModel.muscleGroups.removeAll(where: { $0 == group })
                    } else {
                        viewModel.muscleGroups.append(group)
                    }
                }
            }
        } header: {
            Text("Muscle Groups")
        }
    }
    
    private var categorySection: some View {
        Section {
            Picker("Select Category", selection: $viewModel.category) {
                ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                    Text(cat.description).tag(cat)
                }
            }
            .pickerStyle(.menu)
        } header: {
            Text("Category")
        }
    }
}

#Preview("As sheet") {
    @Previewable @State var isPresented: Bool = true
    Button {
        isPresented = true
    } label: {
        Text("Present")
    }
    .sheet(isPresented: $isPresented) {
        CreateExerciseView(viewModel: CreateExerciseViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
    }
    .previewEnvironment()
}

#Preview("Is saving") {
    @Previewable @State var isPresented: Bool = true
    Button {
        isPresented = true
    } label: {
        Text("Present")
    }
    .sheet(isPresented: $isPresented) {
        CreateExerciseView(viewModel: CreateExerciseViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
    }
    .previewEnvironment()
}

#Preview("As fullscreen cover") {
    @Previewable @State var isPresented: Bool = true
    Button {
        isPresented = true
    } label: {
        Text("Present")
    }
    .fullScreenCover(isPresented: $isPresented) {
        CreateExerciseView(viewModel: CreateExerciseViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
    }
    .previewEnvironment()
    
}
