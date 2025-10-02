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
    @State private var fatTotal: Double?
    @State private var fatSaturated: Double?
    @State private var fatMonounsaturated: Double?
    @State private var fatPolyunsaturated: Double?
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
    
    // Additional minerals
    @State private var chromiumMcg: Double?
    @State private var seleniumMcg: Double?
    @State private var manganeseMg: Double?
    @State private var molybdenumMcg: Double?
    @State private var phosphorusMg: Double?
    @State private var copperMg: Double?
    @State private var chlorideMg: Double?
    @State private var iodineMcg: Double?
    
    // Vitamins
    @State private var vitaminAMcg: Double?
    @State private var vitaminB6Mg: Double?
    @State private var vitaminB12Mcg: Double?
    @State private var vitaminEMg: Double?
    @State private var vitaminKMcg: Double?
    @State private var thiaminMg: Double?
    @State private var riboflavinMg: Double?
    @State private var niacinMg: Double?
    @State private var pantothenicAcidMg: Double?
    @State private var folateMcg: Double?
    @State private var biotinMcg: Double?
    
    // Other compounds
    @State private var caffeineMg: Double?
    @State private var cholesterolMg: Double?

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
                essentialMacroMineralsSection
                essentialTraceMineralsSection
                fatSolubleMineralsSection
                waterSolubleVitaminsSection
                bioactiveCompounts
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
            inputRow(label: "Calories", value: $calories, unit: "kcal")
            inputRow(label: "Protein", value: $protein, unit: "g")
            inputRow(label: "Carbs", value: $carbs, unit: "g")
            inputRow(label: "Total Fat", value: $fatTotal, unit: "g")
            inputRow(label: "Saturated Fat", value: $fatSaturated, unit: "g")
            inputRow(label: "Monounsaturated Fat", value: $fatMonounsaturated, unit: "g")
            inputRow(label: "Polyunsaturated Fat", value: $fatPolyunsaturated, unit: "g")
            inputRow(label: "Fiber", value: $fiber, unit: "g")
            inputRow(label: "Sugar", value: $sugar, unit: "g")
        } header: {
            Text("Macronutrients")
        }
    }

    private var essentialMacroMineralsSection: some View {
        Section {
            // Essential Macrominerals - Required in larger amounts
            inputRow(label: "Calcium", value: $calciumMg, unit: "mg")
            inputRow(label: "Phosphorus", value: $phosphorusMg, unit: "mg")
            inputRow(label: "Magnesium", value: $magnesiumMg, unit: "mg")
            inputRow(label: "Sodium", value: $sodiumMg, unit: "mg")
            inputRow(label: "Potassium", value: $potassiumMg, unit: "mg")
            inputRow(label: "Chloride", value: $chlorideMg, unit: "mg")
        } header: {
            Text("Essential Macrominerals")
        }
    }

    private var essentialTraceMineralsSection: some View {
        Section {
            // Essential Trace Minerals - Required in smaller amounts
            inputRow(label: "Iron", value: $ironMg, unit: "mg")
            inputRow(label: "Zinc", value: $zincMg, unit: "mg")
            inputRow(label: "Copper", value: $copperMg, unit: "mg")
            inputRow(label: "Manganese", value: $manganeseMg, unit: "mg")
            inputRow(label: "Iodine", value: $iodineMcg, unit: "μg")
            inputRow(label: "Selenium", value: $seleniumMcg, unit: "μg")
            inputRow(label: "Molybdenum", value: $molybdenumMcg, unit: "μg")
            inputRow(label: "Chromium", value: $chromiumMcg, unit: "μg")
        } header: {
            Text("Essential Trace Minerals")
        }
    }

    private var fatSolubleMineralsSection: some View {
        Section {
            // Fat-Soluble Vitamins - A, D, E, K
            inputRow(label: "Vitamin A", value: $vitaminAMcg, unit: "μg RAE")
            inputRow(label: "Vitamin D", value: $vitaminDMcg, unit: "μg")
            inputRow(label: "Vitamin E", value: $vitaminEMg, unit: "mg α-tocopherol")
            inputRow(label: "Vitamin K", value: $vitaminKMcg, unit: "μg")
        } header: {
            Text("Fat-Soluble Vitamins")
        }
    }

    private var waterSolubleVitaminsSection: some View {
        Section {
            // Water-Soluble Vitamins - B-Complex & C
            inputRow(label: "Thiamin - B1", value: $thiaminMg, unit: "mg")
            inputRow(label: "Riboflavin - B2", value: $riboflavinMg, unit: "mg")
            inputRow(label: "Niacin - B3", value: $niacinMg, unit: "mg NE")
            inputRow(label: "Pantothenic Acid - B5", value: $pantothenicAcidMg, unit: "mg")
            inputRow(label: "Vitamin B6", value: $vitaminB6Mg, unit: "mg")
            inputRow(label: "Biotin - B7", value: $biotinMcg, unit: "μg")
            inputRow(label: "Folate - B9", value: $folateMcg, unit: "μg DFE")
            inputRow(label: "Vitamin B12", value: $vitaminB12Mcg, unit: "μg")
            inputRow(label: "Vitamin C", value: $vitaminCMg, unit: "mg")
        } header: {
            Text("Water-Soluble Vitamins")
        }
    }
    private var bioactiveCompounts: some View {
        Section {
            // Bioactive Compounds
            inputRow(label: "Cholesterol", value: $cholesterolMg, unit: "mg")
            inputRow(label: "Caffeine", value: $caffeineMg, unit: "mg")
        } header: {
            Text("Bioactive Compounds")
        }
    }

    private func inputRow(label: String, value: Binding<Double?>, unit: String? = nil) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            Text(label)
            Spacer()
            TextField("0", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Text(" " + (unit ?? ""))
                .foregroundStyle(value.wrappedValue != nil ? .primary : .secondary)
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
                ingredientId: UUID().uuidString, authorId: userId,
                name: ingredientName, description: description,
                measurementMethod: measurementMethod, calories: calories,
                protein: protein, carbs: carbs, fatTotal: fatTotal, 
                fatSaturated: fatSaturated, fatMonounsaturated: fatMonounsaturated, 
                fatPolyunsaturated: fatPolyunsaturated, fiber: fiber,
                sugar: sugar, sodiumMg: sodiumMg, potassiumMg: potassiumMg,
                calciumMg: calciumMg, ironMg: ironMg,
                vitaminAMcg: vitaminAMcg, vitaminB6Mg: vitaminB6Mg,
                vitaminB12Mcg: vitaminB12Mcg, vitaminCMg: vitaminCMg,
                vitaminDMcg: vitaminDMcg, vitaminEMg: vitaminEMg,
                vitaminKMcg: vitaminKMcg, magnesiumMg: magnesiumMg,
                zincMg: zincMg, biotinMcg: biotinMcg, copperMg: copperMg,
                folateMcg: folateMcg, iodineMcg: iodineMcg,
                niacinMg: niacinMg, thiaminMg: thiaminMg,
                caffeineMg: caffeineMg, chlorideMg: chlorideMg,
                chromiumMcg: chromiumMcg, seleniumMcg: seleniumMcg,
                manganeseMg: manganeseMg, molybdenumMcg: molybdenumMcg,
                phosphorusMg: phosphorusMg, riboflavinMg: riboflavinMg,
                cholesterolMg: cholesterolMg,
                pantothenicAcidMg: pantothenicAcidMg,
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
