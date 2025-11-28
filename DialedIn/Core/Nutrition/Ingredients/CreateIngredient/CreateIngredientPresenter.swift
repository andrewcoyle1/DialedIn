//
//  CreateIngredientPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI
import PhotosUI

@Observable
@MainActor
class CreateIngredientPresenter {

    private let interactor: CreateIngredientInteractor
    private let router: CreateIngredientRouter

    var selectedPhotoItem: PhotosPickerItem?
    var selectedImageData: Data?
    var isImagePickerPresented: Bool = false
    var name: String?
    var description: String?
    var measurementMethod: MeasurementMethod = .weight
    var calories: Double?
    var protein: Double?
    var carbs: Double?
    var fatTotal: Double?
    var fatSaturated: Double?
    var fatMonounsaturated: Double?
    var fatPolyunsaturated: Double?
    var fiber: Double?
    var sugar: Double?
    var sodiumMg: Double?
    var potassiumMg: Double?
    var calciumMg: Double?
    var ironMg: Double?
    var vitaminCMg: Double?
    var vitaminDMcg: Double?
    var magnesiumMg: Double?
    var zincMg: Double?
    
    // Additional minerals
    var chromiumMcg: Double?
    var seleniumMcg: Double?
    var manganeseMg: Double?
    var molybdenumMcg: Double?
    var phosphorusMg: Double?
    var copperMg: Double?
    var chlorideMg: Double?
    var iodineMcg: Double?
    
    // Vitamins
    var vitaminAMcg: Double?
    var vitaminB6Mg: Double?
    var vitaminB12Mcg: Double?
    var vitaminEMg: Double?
    var vitaminKMcg: Double?
    var thiaminMg: Double?
    var riboflavinMg: Double?
    var niacinMg: Double?
    var pantothenicAcidMg: Double?
    var folateMcg: Double?
    var biotinMcg: Double?
    
    // Other compounds
    var caffeineMg: Double?
    var cholesterolMg: Double?

    var isGenerating: Bool = false
    var generatedImage: UIImage?

    private(set) var isSaving: Bool = false
    
    var canSave: Bool {
        !(name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }
    
    init(
        interactor: CreateIngredientInteractor,
        router: CreateIngredientRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onImageSelectorPressed() {
        // Show the image picker sheet for selecting a profile image
        interactor.trackEvent(event: Event.imageSelectorStart)
        isImagePickerPresented = true
    }

    func onImageSelectorChanged(_ newItem: PhotosPickerItem) async {
        do {
            if let data = try await newItem.loadTransferable(type: Data.self) {
                await MainActor.run {
                    selectedImageData = data
                    interactor.trackEvent(event: Event.imageSelectorSuccess)
                }
            } else {
                await MainActor.run {
                    interactor.trackEvent(event: Event.imageSelectorCancel)
                }
            }
        } catch {
            await MainActor.run {
                interactor.trackEvent(event: Event.imageSelectorFail(error: error))
            }
        }
    }

    func onSavePressed() async {
        guard let ingredientName = name, !isSaving, canSave else { return }
        isSaving = true
        
        do {
            guard let userId = interactor.currentUser?.userId else {
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
            try await interactor.createIngredientTemplate(ingredient: newIngredient, image: uiImage)
#elseif canImport(AppKit)
            let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
            try await interactor.createIngredientTemplate(ingredient: newIngredient, image: nsImage)
#endif
            // Track created template on the user document
            try await interactor.addCreatedIngredientTemplate(ingredientId: newIngredient.id)
            // Auto-bookmark authored templates
            try await interactor.addBookmarkedIngredientTemplate(ingredientId: newIngredient.id)
            try await interactor.bookmarkIngredientTemplate(id: newIngredient.id, isBookmarked: true)
        } catch {
            
        }
        isSaving = false
        router.dismissScreen()
    }
    
    func onCancelPressed() {
        router.dismissScreen()
    }

    func onGenerateImagePressed() {
        isGenerating = true
        Task {
            do {
                interactor.trackEvent(eventName: "AI_Image_Generate_Start", parameters: [
                    "subject": "ingredient",
                    "has_name": !(name?.isEmpty ?? true)
                ], type: .analytic)
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
                generatedImage = try await interactor.generateImage(input: prompt)
                interactor.trackEvent(eventName: "AI_Image_Generate_Success", parameters: [:], type: .analytic)
            } catch {
                interactor.trackEvent(eventName: "AI_Image_Generate_Fail", parameters: error.eventParameters, type: .severe)
                router.showAlert(error: error)
            }
            isGenerating = false
        }
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
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
