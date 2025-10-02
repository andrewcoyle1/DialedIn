//
//  CreateIngredientView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI
import PhotosUI

struct CreateIngredientView: View {

    @Environment(IngredientTemplateManager.self) private var ingredientTemplateManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(AIManager.self) private var aiManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isImagePickerPresented: Bool = false
    
    @State private var name: String?
    @State private var description: String?
    @State private var measurementMethod: MeasurementMethod = .weight
    @State private var calories: Double?
    @State private var protein: Double?
    @State private var carbs: Double?
    @State private var fat: Double?
    @State private var fiber: Double?
    @State private var sugar: Double?
    @State private var sodiumMg: Double?
    @State private var potassiumMg: Double?
    @State private var calciumMg: Double?
    @State private var ironMg: Double?
    @State private var vitaminCMg: Double?
    @State private var vitaminDMcg: Double?
    @State private var magnesiumMg: Double?
    @State private var zincMg: Double?

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif

    @State private var isGenerating: Bool = false
    @State private var generatedImage: UIImage?
    @State private var alert: AnyAppAlert?

    @State var isSaving: Bool = false
    private var canSave: Bool {
        !(name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
    
    var body: some View {
        NavigationStack {
            List {
                imageSection
                nameSection
                macroNutrientSection
                microNutrientSection
            }
            .navigationBarTitle("New Custom Ingredient")
            .navigationSubtitle("Define ingredient details and nutrition")
            .navigationBarTitleDisplayMode(.large)
            .scrollIndicators(.hidden)
            .screenAppearAnalytics(name: "CreateIngredientView")
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
                                    Image(systemName: "carrot.fill")
                                        .font(.system(size: 120))
                                        .foregroundStyle(.accent)
                                }
                                #else
                                Image(systemName: "carrot.fill")
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
                Text("Ingredient Image")
                Spacer()
                Button {
                    onGenerateImagePressed()
                } label: {
                    Image(systemName: "wand.and.sparkles")
                        .font(.system(size: 20))
                }
                .disabled(isGenerating || (name?.isEmpty ?? true))
            }
        }
        .removeListRowFormatting()
    }
    
    private var nameSection: some View {
        Section {
            TextField("Add name", text: Binding(
                get: { name ?? "" },
                set: { newValue in
                    name = newValue.isEmpty ? nil : newValue
                }
            ))
            TextField("Add description", text: Binding(
                get: { description ?? "" },
                set: { newValue in
                    description = newValue.isEmpty ? nil : newValue
                }
            ))
        } header: {
            Text("Name")
        }
    }
    
    private var macroNutrientSection: some View {
        Section {
            HStack {
                Text("Calories")
                TextField("0", value: $calories, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity)
            }
            HStack {
                Text("Protein (g)")
                TextField("0", value: $protein, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity)
            }
            HStack {
                Text("Carbs (g)")
                Spacer()
                TextField("0", value: $carbs, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            HStack {
                Text("Fat (g)")
                Spacer()
                TextField("0", value: $fat, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            HStack {
                Text("Fiber (g)")
                Spacer()
                TextField("0", value: $fiber, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            HStack {
                Text("Sugar (g)")
                Spacer()
                TextField("0", value: $sugar, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
        } header: {
            Text("Macronutrients")
        }
    }
    
    private var microNutrientSection: some View {
        Section {
            HStack {
                Text("Sodium (mg)")
                TextField("0", value: $calories, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity)
            }
            HStack {
                Text("Potassium (mg)")
                TextField("0", value: $protein, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity)
            }
            HStack {
                Text("Calcium (mg)")
                Spacer()
                TextField("0", value: $carbs, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            HStack {
                Text("Iron (mg)")
                Spacer()
                TextField("0", value: $fat, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            HStack {
                Text("Vitamin C (mg)")
                Spacer()
                TextField("0", value: $fiber, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            HStack {
                Text("Vitamin D (mcg)")
                Spacer()
                TextField("0", value: $sugar, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            HStack {
                Text("Magnesium (mg)")
                Spacer()
                TextField("0", value: $sugar, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
            HStack {
                Text("Zinc (mg)")
                Spacer()
                TextField("0", value: $sugar, format: .number)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
            }
        } header: {
            Text("Micronutrients")
        }
    }
    
    private func onImageSelectorPressed() {
        // Show the image picker sheet for selecting a profile image
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
        guard let ingredientName = name, !isSaving, canSave else { return }
        isSaving = true
        
        do {
            guard let userId = userManager.currentUser?.userId else {
                return
            }
            
            let newIngredient = IngredientTemplateModel(
                ingredientId: UUID().uuidString,
                authorId: userId,
                name: ingredientName,
                description: description,
                measurementMethod: measurementMethod,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                fiber: fiber,
                sugar: sugar,
                sodiumMg: sodiumMg,
                potassiumMg: potassiumMg,
                calciumMg: calciumMg,
                ironMg: ironMg,
                vitaminCMg: vitaminCMg,
                vitaminDMcg: vitaminDMcg,
                magnesiumMg: magnesiumMg,
                zincMg: zincMg,
                imageURL: nil,
                dateCreated: Date(),
                dateModified: Date(),
                clickCount: 0
            )
            
#if canImport(UIKit)
            let uiImage = selectedImageData.flatMap { UIImage(data: $0) } ?? generatedImage
            try await ingredientTemplateManager.createIngredientTemplate(ingredient: newIngredient, image: uiImage)
#elseif canImport(AppKit)
            let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
            try await ingredientTemplateManager.createIngredientTemplate(ingredient: newIngredient, image: nsImage)
#endif
            // Track created template on the user document
            try await userManager.addCreatedIngredientTemplate(ingredientId: newIngredient.id)
            // Auto-bookmark authored templates
            try await userManager.addBookmarkedIngredientTemplate(ingredientId: newIngredient.id)
            try await ingredientTemplateManager.bookmarkIngredientTemplate(id: newIngredient.id, isBookmarked: true)
        } catch {
            
        }
        isSaving = false
        dismiss()
    }
    
    private func onCancelPressed() {
        dismiss()
    }

    private func onGenerateImagePressed() {
        isGenerating = true
        Task {
            do {
                logManager.trackEvent(eventName: "AI_Image_Generate_Start", parameters: [
                    "subject": "ingredient",
                    "has_name": !(name?.isEmpty ?? true)
                ])
                let imageDescriptionBuilder = ImageDescriptionBuilder(
                    subject: .ingredient,
                    mode: .marketingConcise,
                    name: name ?? "",
                    description: description,
                    contextNotes: "",
                    desiredStyle: "",
                    backgroundPreference: "",
                    lightingPreference: "",
                    framingNotes: ""
                )
                let prompt = imageDescriptionBuilder.build()
                generatedImage = try await aiManager.generateImage(input: prompt)
                logManager.trackEvent(eventName: "AI_Image_Generate_Success")
            } catch {
                logManager.trackEvent(eventName: "AI_Image_Generate_Fail", parameters: error.eventParameters, type: .severe)
                alert = AnyAppAlert(error: error)
            }
            isGenerating = false
        }
    }

    enum Event: LoggableEvent {
        case createIngredientStart
        case createIngredientSuccess
        case createIngredientFail(error: Error)
        case ingredientGenerateImageStart
        case ingredientGenerateImageSuccess
        case ingredientGenerateImageFail(error: Error)
        case imageSelectorStart
        case imageSelectorSuccess
        case imageSelectorCancel
        case imageSelectorFail(error: Error)

        var eventName: String {
            switch self {
            case .createIngredientStart:          return "CreateIngredient_Start"
            case .createIngredientSuccess:        return "CreateIngredient_Success"
            case .createIngredientFail:           return "CreateIngredient_Fail"
            case .ingredientGenerateImageStart:   return "IngredientGenerateImage_Start"
            case .ingredientGenerateImageSuccess: return "IngredientGenerateImage_Success"
            case .ingredientGenerateImageFail:    return "IngredientGenerateImage_Fail"
            case .imageSelectorStart:           return "IngredientImageSelector_Start"
            case .imageSelectorSuccess:         return "IngredientImageSelector_Success"
            case .imageSelectorCancel:          return "IngredientImageSelector_Cancel"
            case .imageSelectorFail:            return "IngredientImageSelector_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .createIngredientFail(error: let error), .ingredientGenerateImageFail(error: let error), .imageSelectorFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .createIngredientFail, .ingredientGenerateImageFail, .imageSelectorFail:
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
        CreateIngredientView()
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
        CreateIngredientView()
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
        CreateIngredientView()
    }
    .previewEnvironment()
    
}
