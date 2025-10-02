//
//  CreateExerciseView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import PhotosUI

struct CreateExerciseView: View {
    
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(AIManager.self) private var aiManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isImagePickerPresented: Bool = false

    @State private var exerciseName: String?
    @State private var exerciseDescription: String?
    @State private var instructions: [String] = []
    @State private var muscleGroups: [MuscleGroup] = []
    @State private var category: ExerciseCategory = .none

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif

    @State private var isGenerating: Bool = false
    @State private var generatedImage: UIImage?
    @State private var alert: AnyAppAlert?
    
    @State var isSaving: Bool = false
    private var canSave: Bool {
        !(exerciseName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
    
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
                        onCancelPressed()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                #if DEBUG || MOCK
                ToolbarSpacer(.fixed, placement: .topBarLeading)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showDebugView = true
                    } label: {
                        Image(systemName: "info")
                    }
                }
                #endif
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await onSavePressed()
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!canSave || isSaving)
                }
            }
            .onChange(of: selectedPhotoItem) {
                guard let newItem = selectedPhotoItem else { return }
                Task {
                    await onImageSelectorChanged(newItem)
                }
            }
            #if DEBUG || MOCK
            .sheet(isPresented: $showDebugView) {
                DevSettingsView()
            }
            #endif
            .showCustomAlert(alert: $alert)
        }
    }

    private var imageSection: some View {
        Section {
            HStack {
                Spacer()
                Button {
                    onImageSelectorPressed()
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.001))
                        Group {
                            if let data = selectedImageData {
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
                                if let generatedImage {
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
                .photosPicker(isPresented: $isImagePickerPresented, selection: $selectedPhotoItem, matching: .images)
                Spacer()
            }
        } header: {
            HStack {
                Text("Exercise Image")
                Spacer()
                Button {
                    onGenerateImagePressed()
                } label: {
                    Image(systemName: "wand.and.sparkles")
                        .font(.system(size: 20))
                }
                .disabled(isGenerating || (exerciseName?.isEmpty ?? true))
            }
        }
        .removeListRowFormatting()
    }

    private var nameSection: some View {
        Section {
            TextField("Add name", text: Binding(
                get: { exerciseName ?? "" },
                set: { newValue in
                    exerciseName = newValue.isEmpty ? nil : newValue
                }
            ))
            TextField("Add description", text: Binding(
                get: { exerciseDescription ?? "" },
                set: { newValue in
                    exerciseDescription = newValue.isEmpty ? nil : newValue
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
                    isSelected: muscleGroups.contains(group)
                ) {
                    if muscleGroups.contains(group) {
                        muscleGroups.removeAll(where: { $0 == group })
                    } else {
                        muscleGroups.append(group)
                    }
                }
            }
        } header: {
            Text("Muscle Groups")
        }
    }
    
    private var categorySection: some View {
        Section {
            Picker("Select Category", selection: $category) {
                ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                    Text(cat.description).tag(cat)
                }
            }
            .pickerStyle(.menu)
        } header: {
            Text("Category")
        }
    }
    
    private func onImageSelectorPressed() {
        // Show the image picker sheet for selecting an image
        logManager.trackEvent(event: Event.imageSelectorStart)
        isImagePickerPresented = true
    }

    private func onImageSelectorChanged(_ newItem: PhotosPickerItem) async {
        do {
            if let data = try await newItem.loadTransferable(type: Data.self) {
                await MainActor.run {
                    selectedImageData = data
                    logManager.trackEvent(event: Event.imageSelectorSuccess)
                }
            } else {
                await MainActor.run {
                    logManager.trackEvent(event: Event.imageSelectorCancel)
                }
            }
        } catch {
            await MainActor.run {
                logManager.trackEvent(event: Event.imageSelectorFail(error: error))
            }
        }
    }

    private func onSavePressed() async {
        guard let exerciseName, !isSaving, canSave else { return }
        isSaving = true
        
        do {
            logManager.trackEvent(event: Event.createExerciseStart)
            guard let userId = userManager.currentUser?.userId else {
                return
            }
            
            let newExercise = ExerciseTemplateModel(
                exerciseId: UUID().uuidString,
                authorId: userId,
                name: exerciseName,
                description: exerciseDescription,
                instructions: instructions,
                type: category,
                muscleGroups: muscleGroups,
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 0
            )
            
            #if canImport(UIKit)
            let uiImage = selectedImageData.flatMap { UIImage(data: $0) } ?? generatedImage
            try await exerciseTemplateManager.createExerciseTemplate(exercise: newExercise, image: uiImage)
            #elseif canImport(AppKit)
            let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
            try await exerciseTemplateManager.createExerciseTemplate(exercise: newExercise, image: nsImage)
            #endif
            // Track created template on the user document
            try await userManager.addCreatedExerciseTemplate(exerciseId: newExercise.id)
            // Auto-bookmark authored templates
            try await userManager.addBookmarkedExerciseTemplate(exerciseId: newExercise.id)
            try await exerciseTemplateManager.bookmarkExerciseTemplate(id: newExercise.id, isBookmarked: true)
            logManager.trackEvent(event: Event.createExerciseSuccess)
        } catch {
            logManager.trackEvent(event: Event.createExerciseFail(error: error))
            alert = AnyAppAlert(title: "Unable to save exercise", subtitle: "Please check your internet connection and try again.")
            isSaving = false
            return
        }
        isSaving = false
        dismiss()
    }

    private func onGenerateImagePressed() {
        isGenerating = true
        Task {
            do {
                logManager.trackEvent(event: Event.exerciseGenerateImageStart)
                let imageDescriptionBuilder = ImageDescriptionBuilder(
                    subject: .exercise,
                    mode: .marketingConcise,
                    name: exerciseName ?? "",
                    description: exerciseDescription,
                    contextNotes: "",
                    desiredStyle: "",
                    backgroundPreference: "",
                    lightingPreference: "",
                    framingNotes: ""
                )

                let prompt = imageDescriptionBuilder.build()

                generatedImage = try await aiManager.generateImage(input: prompt)
                logManager.trackEvent(event: Event.exerciseGenerateImageSuccess)
            } catch {
                logManager.trackEvent(event: Event.exerciseGenerateImageFail(error: error))
                alert = AnyAppAlert(title: "Unable to generate image", subtitle: "Please try again later.")
            }
            isGenerating = false
        }
    }

    private func onCancelPressed() {
        dismiss()
    }

    enum Event: LoggableEvent {
        case createExerciseStart
        case createExerciseSuccess
        case createExerciseFail(error: Error)
        case exerciseGenerateImageStart
        case exerciseGenerateImageSuccess
        case exerciseGenerateImageFail(error: Error)
        case imageSelectorStart
        case imageSelectorSuccess
        case imageSelectorCancel
        case imageSelectorFail(error: Error)

        var eventName: String {
            switch self {
            case .createExerciseStart:          return "CreateExercise_Start"
            case .createExerciseSuccess:        return "CreateExercise_Success"
            case .createExerciseFail:           return "CreateExercise_Fail"
            case .exerciseGenerateImageStart:   return "ExerciseGenerateImage_Start"
            case .exerciseGenerateImageSuccess: return "ExerciseGenerateImage_Success"
            case .exerciseGenerateImageFail:    return "ExerciseGenerateImage_Fail"
            case .imageSelectorStart:           return "ExerciseImageSelector_Start"
            case .imageSelectorSuccess:         return "ExerciseImageSelector_Success"
            case .imageSelectorCancel:          return "ExerciseImageSelector_Cancel"
            case .imageSelectorFail:            return "ExerciseImageSelector_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .createExerciseFail(error: let error), .exerciseGenerateImageFail(error: let error), .imageSelectorFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .createExerciseFail, .exerciseGenerateImageFail, .imageSelectorFail:
                return .severe
            default:
                return .analytic

            }
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
        CreateExerciseView()
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
        CreateExerciseView()
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
        CreateExerciseView()
    }
    .previewEnvironment()
    
}
