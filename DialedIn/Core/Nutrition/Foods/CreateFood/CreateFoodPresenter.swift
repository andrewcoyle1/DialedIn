//
//  CreateFoodPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 26/10/2025.
//

import SwiftUI
import PhotosUI

@Observable
@MainActor
class CreateFoodPresenter {

    private let interactor: CreateFoodInteractor
    private let router: CreateFoodRouter

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
        interactor: CreateFoodInteractor,
        router: CreateFoodRouter
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
    
    func onNextPressed(delegate: CreateFoodDelegate) {
        if contributeToPublicDatabase {
            #if canImport(UIKit)
            let uiImage = selectedImageData.flatMap { UIImage(data: $0) }
            router.showFoodPackagingView(
                delegate: FoodPackagingDelegate(
                    mealItems: delegate.mealItems,
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
                    mealItems: delegate.mealItems,
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
                    mealItems: delegate.mealItems,
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
                    mealItems: delegate.mealItems,
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
        case createFoodStart
        case createFoodSuccess
        case createFoodFail(error: Error)
        case imageSelectorStart
        case imageSelectorSuccess
        case imageSelectorCancel
        case imageSelectorFail(error: Error)

        var eventName: String {
            switch self {
            case .onAppear:                         return "CreateFoodView_Appear"
            case .onDisappear:                      return "CreateFoodView_Disappear"
            case .createFoodStart:            return "CreateFood_Start"
            case .createFoodSuccess:          return "CreateFood_Success"
            case .createFoodFail:             return "CreateFood_Fail"
            case .imageSelectorStart:               return "IngredientImageSelector_Start"
            case .imageSelectorSuccess:             return "IngredientImageSelector_Success"
            case .imageSelectorCancel:              return "IngredientImageSelector_Cancel"
            case .imageSelectorFail:                return "IngredientImageSelector_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .createFoodFail(error: let error), .imageSelectorFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .createFoodFail, .imageSelectorFail:
                return .severe
            default:
                return .analytic

            }
        }
    }
}
