import SwiftUI

struct FoodPhotoScannerDelegate {
    let onPick: (MealItemModel) -> Void
}

struct FoodPhotoScannerView: View {

    @State var presenter: FoodPhotoScannerPresenter
    let delegate: FoodPhotoScannerDelegate

    @State private var capturedImage: UIImage?
    @State private var shouldCapture: Bool = false

    var body: some View {
        Group {
            if let image = capturedImage {
                if presenter.isAnalysing {
                    analysingPhase(image: image)
                } else {
                    resultsPhase(image: image)
                }
            } else {
                cameraPhase
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            presenter.onViewAppear()
        }
    }

    // MARK: - Phases

    private var cameraPhase: some View {
        ZStack(alignment: .bottom) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                CameraCapture(shouldCapture: $shouldCapture) { image in
                    capturedImage = image
                    Task {
                        await presenter.onCapture(image)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all, edges: .bottom)

                captureButton
                    .padding(.bottom, 40)
            } else {
                Text("Camera not available on this device.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func analysingPhase(image: UIImage) -> some View {
        VStack(spacing: 20) {
            thumbnailView(image: image)
            ProgressView("Analysing meal...")
                .progressViewStyle(.circular)
            retakeButton
        }
        .padding()
    }

    private func resultsPhase(image: UIImage) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                thumbnailView(image: image)

                if let error = presenter.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ForEach(presenter.analysisResults) { item in
                        resultRow(for: item)
                    }
                }

                retakeButton
                    .padding(.bottom)
            }
            .padding()
        }
    }

    // MARK: - Subviews

    private var captureButton: some View {
        Button {
            shouldCapture = true
        } label: {
            Image(systemName: "camera.circle.fill")
                .resizable()
                .frame(width: 70, height: 70)
                .foregroundStyle(.white)
                .shadow(radius: 4)
        }
    }

    private func thumbnailView(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var retakeButton: some View {
        Button("Retake") {
            capturedImage = nil
            presenter.onRetakePressed()
        }
        .buttonStyle(.bordered)
    }

    private func resultRow(for item: FoodAnalysisItem) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.headline)
                Text("\(Int(item.amountGrams))g")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    if let cal = item.calories {
                        macroChip("\(Int(cal)) kcal", color: .orange)
                    }
                    if let protein = item.proteinGrams {
                        macroChip("P \(formatted(protein))g", color: .blue)
                    }
                    if let carbs = item.carbGrams {
                        macroChip("C \(formatted(carbs))g", color: .green)
                    }
                    if let fat = item.fatGrams {
                        macroChip("F \(formatted(fat))g", color: .yellow)
                    }
                }
            }
            Spacer()
            Button("Add") {
                delegate.onPick(presenter.makeMealItem(from: item))
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func macroChip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.2), in: Capsule())
    }

    private func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }
}

// MARK: - CameraCapture

struct CameraCapture: UIViewControllerRepresentable {

    @Binding var shouldCapture: Bool
    var onCapture: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return UIViewController()
        }
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.showsCameraControls = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.parent = self
        if shouldCapture, let picker = uiViewController as? UIImagePickerController {
            picker.takePicture()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraCapture

        init(_ parent: CameraCapture) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            parent.shouldCapture = false
            if let image = info[.originalImage] as? UIImage {
                parent.onCapture(image)
            }
        }
    }
}

// MARK: - CoreBuilder

extension CoreBuilder {
    func foodPhotoScannerView(router: AnyRouter, delegate: FoodPhotoScannerDelegate) -> some View {
        FoodPhotoScannerView(
            presenter: FoodPhotoScannerPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}

// MARK: - Preview

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = FoodPhotoScannerDelegate(onPick: { item in
        print(item.displayName)
    })

    return RouterView { router in
        builder.foodPhotoScannerView(router: router, delegate: delegate)
    }
}
