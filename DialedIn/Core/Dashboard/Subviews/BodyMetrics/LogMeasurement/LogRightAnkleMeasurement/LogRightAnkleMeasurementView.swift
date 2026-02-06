//
//  LogRightAnkleMeasurementView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 06/02/2026.
//

import SwiftUI
import SwiftfulRouting

struct LogRightAnkleMeasurementView: View {

    @State var presenter: LogRightAnkleMeasurementPresenter
    
    var body: some View {
        List {
            dateSection
                .removeListRowFormatting()
            unitPickerSection
            measurementPickerSection
        }
        .navigationTitle("Log Right Ankle Measurement")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .task {
            await presenter.loadInitialData()
        }
    }
    
    private var dateSection: some View {
        Section {
            DatePicker(
                "Date",
                selection: $presenter.selectedDate,
                in: ...Date(),
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
        } header: {
            Text("Date")
        } footer: {
            Text("Select the date for this measurement entry")
        }
    }
    
    private var unitPickerSection: some View {
        Section {
            Picker("Units", selection: $presenter.unit) {
                Text("Metric (cm)").tag(UnitOfLength.centimeters)
                Text("Imperial (in)").tag(UnitOfLength.inches)
            }
            .pickerStyle(.segmented)
        }
        .removeListRowFormatting()
    }
    
    private var measurementPickerSection: some View {
        Section {
            if presenter.unit == .centimeters {
                Picker("Right Ankle Circumference", selection: $presenter.selectedCentimeters) {
                    ForEach((18...30).reversed(), id: \.self) { value in
                        Text("\(value) cm").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .clipped()
                .onChange(of: presenter.selectedCentimeters) { _, newValue in
                    presenter.selectedInches = Int(Double(newValue) / 2.54)
                }
            } else {
                Picker("Right Ankle Circumference", selection: $presenter.selectedInches) {
                    ForEach((7...12).reversed(), id: \.self) { value in
                        Text("\(value) in").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .clipped()
                .onChange(of: presenter.selectedInches) { _, newValue in
                    presenter.selectedCentimeters = Int(Double(newValue) * 2.54)
                }
            }
        } header: {
            Text("Right Ankle Circumference")
        }
        .removeListRowFormatting()
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(role: .close) {
                presenter.onDismissPressed()
            }
        }
        
        ToolbarItem(placement: .primaryAction) {
            Button(role: .confirm) {
                Task {
                    await presenter.saveMeasurement()
                }
            }
            .disabled(presenter.isLoading)
        }
    }
}

extension CoreBuilder {
    func logRightAnkleMeasurementView(router: AnyRouter) -> some View {
        LogRightAnkleMeasurementView(
            presenter: LogRightAnkleMeasurementPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showLogRightAnkleMeasurementView() {
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.5)]))) { router in
            builder.logRightAnkleMeasurementView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.logRightAnkleMeasurementView(router: router)
    }
    .previewEnvironment()
}
