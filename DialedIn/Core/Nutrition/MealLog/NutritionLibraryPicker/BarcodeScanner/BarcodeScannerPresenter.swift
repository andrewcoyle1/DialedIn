import SwiftUI
import VisionKit

@Observable
@MainActor
class BarcodeScannerPresenter {

    private let interactor: BarcodeScannerInteractor
    private let router: BarcodeScannerRouter

    var isScanning: Bool = false
    var scannedCode: String?

    var scanningMode: ScanningMode = .barcode
    var recognisedTypes: Set<DataScannerViewController.RecognizedDataType> = [.barcode()]

    // MARK: Label scanning state
    private(set) var isParsingLabel: Bool = false
    private(set) var parsedIngredient: IngredientTemplateModel?
    private(set) var labelError: String?
    private(set) var isSavingIngredient: Bool = false
    private(set) var savedSuccessfully: Bool = false

    init(interactor: BarcodeScannerInteractor, router: BarcodeScannerRouter) {
        self.interactor = interactor
        self.router = router
    }

    func onViewAppear(delegate: BarcodeScannerDelegate) {
        interactor.trackScreenEvent(event: Event.onAppear(delegate: delegate))
        isScanning = true
    }

    func onViewDisappear(delegate: BarcodeScannerDelegate) {
        interactor.trackEvent(event: Event.onDisappear(delegate: delegate))
        isScanning = false
    }

    // MARK: Label mode actions

    func onParseLabelPressed() async {
        guard let text = scannedCode, !text.isEmpty, !isParsingLabel else { return }
        isParsingLabel = true
        labelError = nil
        parsedIngredient = nil
        interactor.trackEvent(event: Event.onParseLabel)

        do {
            let json = try await interactor.analyzeNutritionLabel(text: text)
            let decoded = try JSONDecoder().decode(NutritionLabelResponse.self, from: Data(json.utf8))
            parsedIngredient = decoded.toIngredientTemplate(authorId: interactor.currentUser?.userId)
        } catch {
            labelError = error.localizedDescription
            interactor.trackEvent(event: Event.onLabelError(message: error.localizedDescription))
        }
        isParsingLabel = false
    }

    func onSaveIngredientPressed() async {
        guard let ingredient = parsedIngredient, !isSavingIngredient else { return }
        isSavingIngredient = true
        interactor.trackEvent(event: Event.onSaveIngredient(name: ingredient.name))

        do {
            try await interactor.saveIngredientTemplate(ingredient, image: nil)
            savedSuccessfully = true
            parsedIngredient = nil
            scannedCode = nil
            isScanning = true
        } catch {
            labelError = error.localizedDescription
            interactor.trackEvent(event: Event.onLabelError(message: error.localizedDescription))
        }
        isSavingIngredient = false
    }

    func onDismissLabelResultPressed() {
        parsedIngredient = nil
        labelError = nil
        savedSuccessfully = false
        isScanning = true
    }

    func onRescanPressed() {
        scannedCode = nil
        parsedIngredient = nil
        labelError = nil
        isScanning = true
    }
    
    func onDismissPressed() {
        router.dismissScreen()
    }
}

extension BarcodeScannerPresenter {

    enum Event: LoggableEvent {
        case onAppear(delegate: BarcodeScannerDelegate)
        case onDisappear(delegate: BarcodeScannerDelegate)
        case onParseLabel
        case onSaveIngredient(name: String)
        case onLabelError(message: String)

        var eventName: String {
            switch self {
            case .onAppear:          return "BarcodeScannerView_Appear"
            case .onDisappear:       return "BarcodeScannerView_Disappear"
            case .onParseLabel:      return "BarcodeScanner_ParseLabel"
            case .onSaveIngredient:  return "BarcodeScanner_SaveIngredient"
            case .onLabelError:      return "BarcodeScanner_LabelError"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onAppear(let delegate), .onDisappear(let delegate):
                return delegate.eventParameters
            case .onSaveIngredient(let name):
                return ["ingredient_name": name]
            case .onLabelError(let message):
                return ["error": message]
            default:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .onLabelError: return .severe
            default:            return .analytic
            }
        }
    }
}

enum ScanningMode: String, CaseIterable, Identifiable {
    var id: String { self.rawValue }
    case barcode
    case label

    var recognisedTypes: Set<DataScannerViewController.RecognizedDataType> {
        switch self {
        case .barcode: return [.barcode()]
        case .label:   return [.text()]
        }
    }
}

// MARK: - NutritionLabelResponse

private struct NutritionLabelResponse: Decodable {
    let name: String
    let measurementMethod: String?
    let calories: Double?
    let protein: Double?
    let carbs: Double?
    let fatTotal: Double?
    let fatSaturated: Double?
    let fiber: Double?
    let sugar: Double?
    let sodiumMg: Double?
    let potassiumMg: Double?
    let calciumMg: Double?
    let ironMg: Double?

    func toIngredientTemplate(authorId: String?) -> IngredientTemplateModel {
        let method: MeasurementMethod = measurementMethod == "volume" ? .volume : .weight
        let now = Date()
        return IngredientTemplateModel(
            ingredientId: UUID().uuidString,
            authorId: authorId,
            name: name,
            measurementMethod: method,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fatTotal: fatTotal,
            fatSaturated: fatSaturated,
            fiber: fiber,
            sugar: sugar,
            sodiumMg: sodiumMg,
            potassiumMg: potassiumMg,
            calciumMg: calciumMg,
            ironMg: ironMg,
            dateCreated: now,
            dateModified: now
        )
    }
}
