//
//  CreateExerciseView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import PhotosUI
import SwiftfulRouting

struct CreateExerciseView: View {

    @State var presenter: CreateExercisePresenter

    var body: some View {
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
            toolbarContent
        }
        .onChange(of: presenter.selectedPhotoItem) {
            guard let newItem = presenter.selectedPhotoItem else { return }
            Task {
                await presenter.onImageSelectorChanged(newItem)
            }
        }
    }

    private var imageSection: some View {
        Section {
            HStack {
                Spacer()
                Button {
                    presenter.onImageSelectorPressed()
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.001))
                        Group {
                            if let data = presenter.selectedImageData {
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
                                if let generatedImage = presenter.generatedImage {
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
                .photosPicker(isPresented: $presenter.isImagePickerPresented, selection: $presenter.selectedPhotoItem, matching: .images)
                Spacer()
            }
        } header: {
            HStack {
                Text("Exercise Image")
                Spacer()
                Button {
                    presenter.onGenerateImagePressed()
                } label: {
                    Image(systemName: "wand.and.sparkles")
                        .font(.system(size: 20))
                }
                .disabled(presenter.isGenerating || (presenter.exerciseName?.isEmpty ?? true))
            }
        }
        .removeListRowFormatting()
    }

    private var nameSection: some View {
        Section {
            TextField("Add name", text: Binding(
                get: { presenter.exerciseName ?? "" },
                set: { newValue in
                    presenter.exerciseName = newValue.isEmpty ? nil : newValue
                }
            ))
            TextField("Add description", text: Binding(
                get: { presenter.exerciseDescription ?? "" },
                set: { newValue in
                    presenter.exerciseDescription = newValue.isEmpty ? nil : newValue
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
                    isSelected: presenter.muscleGroups.contains(group)
                ) {
                    if presenter.muscleGroups.contains(group) {
                        presenter.muscleGroups.removeAll(where: { $0 == group })
                    } else {
                        presenter.muscleGroups.append(group)
                    }
                }
            }
        } header: {
            Text("Muscle Groups")
        }
    }
    
    private var categorySection: some View {
        Section {
            Picker("Select Category", selection: $presenter.category) {
                ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                    Text(cat.description).tag(cat)
                }
            }
            .pickerStyle(.menu)
        } header: {
            Text("Category")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onCancelPressed()
            } label: {
                Image(systemName: "xmark")
            }
        }
        #if DEBUG || MOCK
        ToolbarSpacer(.fixed, placement: .topBarLeading)
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task {
                    await presenter.onSavePressed()
                }
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.glassProminent)
            .disabled(!presenter.canSave || presenter.isSaving)
        }

    }
}

#Preview("As sheet") {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.createExerciseView(router: router)
    }
    .previewEnvironment()
}

#Preview("Is saving") {
    @Previewable @State var isPresented: Bool = true
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.createExerciseView(router: router)
    }
    .previewEnvironment()
}

#Preview("As fullscreen cover") {
    @Previewable @State var isPresented: Bool = true
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.createExerciseView(router: router)
    }
    .previewEnvironment()
}
