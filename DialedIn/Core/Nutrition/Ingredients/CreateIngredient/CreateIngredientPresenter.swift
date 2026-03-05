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
    var name: String = ""
    var brandName: String?
    var barcode: String?
    var contributeToPublicDatabase: Bool = false

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(
        interactor: CreateIngredientInteractor,
        router: CreateIngredientRouter
    ) {
        self.interactor = interactor
        self.router = router
    }
    
    func onViewAppear() {
        interactor.trackScreenEvent(event: Event.onAppear)
    }
    
    func onViewDisappear() {
        interactor.trackEvent(event: Event.onDisappear)
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
    
    func onCancelPressed() {
        router.dismissScreen()
    }
    
    func onNextPressed() {
        if contributeToPublicDatabase {
            #if canImport(UIKit)
            let uiImage = selectedImageData.flatMap { UIImage(data: $0) }
            router.showFoodPackagingView(
                delegate: FoodPackagingDelegate(
                    name: self.name,
                    brandName: self.brandName,
                    barcode: self.barcode,
                    image: uiImage
                )
            )
            #elseif canImport(AppKit)
            let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
            router.showFoodPackagingView(
                delegate: FoodPackagingDelegate(
                    name: self.name,
                    brandName: self.brandName,
                    barcode: self.barcode,
                    image: nsImage
                )
            )
            #endif
        } else {
            #if canImport(UIKit)
            let uiImage = selectedImageData.flatMap { UIImage(data: $0) }
            router.showPortionDefinitionView(
                delegate: PortionDefinitionDelegate(
                    name: self.name,
                    brandName: self.brandName,
                    barcode: self.barcode,
                    image: uiImage,
                    productFront: nil,
                    nutritionPhoto: nil
                )
            )
            #elseif canImport(AppKit)
            let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
            router.showPortionDefinitionView(
                delegate: PortionDefinitionDelegate(
                    name: self.name,
                    brandName: self.brandName,
                    barcode: self.barcode,
                    image: nsImage,
                    productFront: nil,
                    nutritionPhoto: nil
                )
            )
            #endif
        }
    }
    
    func onLearnMorePressed() {
        
    }
    
    func onBarcodeScannerPressed() {
        router.showBarcodeScannerView(
            delegate: BarcodeScannerDelegate(
                onBarcodeScanned: { barcode in
                    self.barcode = barcode
                }
            )
        )
    }

#if DEV || MOCK
func onDevSettingsPressed() {
    router.showDevSettingsView()
}
#endif

    enum Event: LoggableEvent {
        case onAppear
        case onDisappear
        case createIngredientStart
        case createIngredientSuccess
        case createIngredientFail(error: Error)
        case imageSelectorStart
        case imageSelectorSuccess
        case imageSelectorCancel
        case imageSelectorFail(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:                         return "CreateIngredientView_Appear"
            case .onDisappear:                      return "CreateIngredientView_Disappear"
            case .createIngredientStart:            return "CreateIngredient_Start"
            case .createIngredientSuccess:          return "CreateIngredient_Success"
            case .createIngredientFail:             return "CreateIngredient_Fail"
            case .imageSelectorStart:               return "IngredientImageSelector_Start"
            case .imageSelectorSuccess:             return "IngredientImageSelector_Success"
            case .imageSelectorCancel:              return "IngredientImageSelector_Cancel"
            case .imageSelectorFail:                return "IngredientImageSelector_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .createIngredientFail(error: let error), .imageSelectorFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .createIngredientFail, .imageSelectorFail:
                return .severe
            default:
                return .analytic

            }
        }
    }
}
