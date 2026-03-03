import SwiftUI
import VisionKit

struct BarcodeScannerDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct BarcodeScannerView: View {

    @State var presenter: BarcodeScannerPresenter
    let delegate: BarcodeScannerDelegate

    var body: some View {
        ZStack {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                BarcodeScanner(
                    isScanning: $presenter.isScanning,
                    scannedCode: $presenter.scannedCode,
                    recognizedDataTypes: $presenter.recognisedTypes,
                    scanningMode: presenter.scanningMode
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)

                VStack {
                    topControls
                    Spacer()
                    if presenter.scanningMode == .barcode {
                        barcodeBottomDisplay
                    } else {
                        labelModeBottomBar
                    }
                }

                if presenter.parsedIngredient != nil || (presenter.isParsingLabel == false && presenter.labelError != nil) {
                    parsedIngredientOverlay
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(duration: 0.3), value: presenter.parsedIngredient != nil)
                }
            } else {
                Text("Scanner not supported on this device.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onChange(of: presenter.scanningMode) { _, newValue in
            presenter.recognisedTypes = newValue.recognisedTypes
            presenter.onRescanPressed()
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }

    // MARK: - Top controls

    private var topControls: some View {
        HStack {
            Picker("", selection: $presenter.scanningMode) {
                ForEach(ScanningMode.allCases) { mode in
                    Text(mode.rawValue.capitalized).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 120)

            Spacer()

            Button {
            } label: {
                Image(systemName: "keyboard")
                    .padding()
                    .background(.secondary, in: .circle)
            }
            Button {
            } label: {
                Image(systemName: "flashlight.on.fill")
                    .padding()
                    .background(.secondary, in: .circle)
            }
        }
        .padding()
    }

    // MARK: - Barcode bottom display

    @ViewBuilder
    private var barcodeBottomDisplay: some View {
        if let code = presenter.scannedCode {
            Text("Scanned: \(code)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding()
                .background(.secondary, in: .capsule)
                .padding(.bottom)
        }
    }

    // MARK: - Label mode bottom bar

    private var labelModeBottomBar: some View {
        VStack(spacing: 10) {
            if presenter.isParsingLabel {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("Analysing label...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(.regularMaterial, in: Capsule())

                Button("Re-scan", action: presenter.onRescanPressed)
                    .buttonStyle(.bordered)
            } else if presenter.scannedCode != nil {
                Text("Label text captured")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Button("Re-scan", action: presenter.onRescanPressed)
                        .buttonStyle(.bordered)

                    Button("Parse Label") {
                        Task { await presenter.onParseLabelPressed() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                Text("Point camera at a nutrition label")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(.regularMaterial, in: Capsule())
            }
        }
        .padding(.bottom, 32)
    }

    // MARK: - Parsed ingredient overlay

    private var parsedIngredientOverlay: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture { presenter.onDismissLabelResultPressed() }
            parsedIngredientCard
        }
    }

    private var parsedIngredientCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let ingredient = presenter.parsedIngredient {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(ingredient.name)
                            .font(.title3.bold())
                        Spacer()
                        Text("per 100g")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let description = ingredient.description {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Macros row
                HStack(spacing: 8) {
                    if let cal = ingredient.calories {
                        macroChip("\(Int(cal)) kcal", color: .orange)
                    }
                    if let protein = ingredient.protein {
                        macroChip("P \(formatted(protein))g", color: .blue)
                    }
                    if let carbs = ingredient.carbs {
                        macroChip("C \(formatted(carbs))g", color: .green)
                    }
                    if let fatTotal = ingredient.fatTotal {
                        macroChip("F \(formatted(fatTotal))g", color: .yellow)
                    }
                }

                // Secondary nutrients
                let secondaryItems: [(String, Double?, String)] = [
                    ("Fiber", ingredient.fiber, "g"),
                    ("Sugar", ingredient.sugar, "g"),
                    ("Sat fat", ingredient.fatSaturated, "g"),
                    ("Sodium", ingredient.sodiumMg, "mg"),
                    ("Potassium", ingredient.potassiumMg, "mg"),
                    ("Calcium", ingredient.calciumMg, "mg"),
                    ("Iron", ingredient.ironMg, "mg")
                ]
                let available = secondaryItems.compactMap { name, value, unit -> (String, Double, String)? in
                    guard let val = value else { return nil }
                    return (name, val, unit)
                }
                if !available.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(available, id: \.0) { name, value, unit in
                            Text("\(name): \(formatted(value))\(unit)")
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.quaternary, in: Capsule())
                        }
                    }
                }

            } else if let error = presenter.labelError {
                Label(error, systemImage: "exclamationmark.triangle")
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.leading)
            }

            // Action buttons
            HStack(spacing: 12) {
                Button("Dismiss") {
                    presenter.onDismissLabelResultPressed()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)

                if presenter.parsedIngredient != nil {
                    Button {
                        Task { await presenter.onSaveIngredientPressed() }
                    } label: {
                        if presenter.isSavingIngredient {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Save to Library")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(presenter.isSavingIngredient)
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 12)
        .padding(.bottom, 32)
    }

    // MARK: - Helpers

    private func macroChip(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.2), in: Capsule())
    }

    private func formatted(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(value))
            : String(format: "%.1f", value)
    }
}

// MARK: - BarcodeScanner (UIViewControllerRepresentable)

struct BarcodeScanner: UIViewControllerRepresentable {
    @Binding var isScanning: Bool
    @Binding var scannedCode: String?
    @Binding var recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType>
    var scanningMode: ScanningMode

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let controller = DataScannerViewController(
            recognizedDataTypes: recognizedDataTypes,
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        context.coordinator.parent = self
        if isScanning {
            try? uiViewController.startScanning()
        } else {
            uiViewController.stopScanning()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: BarcodeScanner

        init(_ parent: BarcodeScanner) {
            self.parent = parent
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didAdd addedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            switch parent.scanningMode {
            case .barcode:
                guard let item = addedItems.first,
                      case let .barcode(barcode) = item,
                      let payload = barcode.payloadStringValue else { return }
                parent.scannedCode = payload
                parent.isScanning = false
            case .label:
                let text = allItems.compactMap { item -> String? in
                    if case let .text(textItem) = item { return textItem.transcript }
                    return nil
                }.joined(separator: "\n")
                guard !text.isEmpty else { return }
                parent.scannedCode = text
                // Don't stop scanning — user triggers analysis manually
            }
        }
    }
}

// MARK: - FlowLayout

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map { $0.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0 }
            .reduce(0) { $0 + $1 + spacing } - spacing
        return CGSize(width: proposal.width ?? 0, height: max(height, 0))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var yVal = bounds.minY
        for row in rows {
            var xVal = bounds.minX
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: xVal, y: yVal), proposal: .unspecified)
                xVal += size.width + spacing
            }
            yVal += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [[LayoutSubview]] = [[]]
        var rowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth && !rows[rows.count - 1].isEmpty {
                rows.append([])
                rowWidth = 0
            }
            rows[rows.count - 1].append(subview)
            rowWidth += size.width + spacing
        }
        return rows
    }
}

// MARK: - CoreBuilder

extension CoreBuilder {

    func barcodeScannerView(router: AnyRouter, delegate: BarcodeScannerDelegate) -> some View {
        BarcodeScannerView(
            presenter: BarcodeScannerPresenter(
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
    let delegate = BarcodeScannerDelegate()

    return RouterView { router in
        builder.barcodeScannerView(router: router, delegate: delegate)
    }
}
