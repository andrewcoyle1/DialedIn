//
//  LogWeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct LogWeightView: View {

    @State var presenter: LogWeightPresenter
    
    var body: some View {
        List {
            dateSection
                .removeListRowFormatting()
            unitPickerSection
            weightPickerSection
        }
        .navigationTitle("Log Weight")
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
            Text("Select the date for this weight entry")
        }
    }
    
    private var unitPickerSection: some View {
        Section {
            Picker("Units", selection: $presenter.unit) {
                Text("Metric (kg)").tag(UnitOfWeight.kilograms)
                Text("Imperial (lbs)").tag(UnitOfWeight.pounds)
            }
            .pickerStyle(.segmented)
        }
        .removeListRowFormatting()
    }
    
    private var weightPickerSection: some View {
        Section {
            if presenter.unit == .kilograms {
                Picker("Weight", selection: $presenter.selectedKilograms) {
                    ForEach((30...200).reversed(), id: \.self) { value in
                        Text("\(value) kg").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .clipped()
                .onChange(of: presenter.selectedKilograms) { _, newValue in
                    // Update pounds to match
                    presenter.selectedPounds = Int(Double(newValue) * 2.20462)
                }
            } else {
                Picker("Weight", selection: $presenter.selectedPounds) {
                    ForEach((66...440).reversed(), id: \.self) { value in
                        Text("\(value) lbs").tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .clipped()
                .onChange(of: presenter.selectedPounds) { _, newValue in
                    // Update kilograms to match
                    presenter.selectedKilograms = Int(Double(newValue) * 0.453592)
                }
            }
        } header: {
            Text("Weight")
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
                    await presenter.saveWeight()
                }
            }
            .disabled(presenter.isLoading)
        }
    }
}

extension CoreBuilder {
    func logWeightView(router: AnyRouter) -> some View {
        LogWeightView(
            presenter: LogWeightPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showLogWeightView() {
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.5)]))) { router in
            builder.logWeightView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.logWeightView(router: router)
    }
    .previewEnvironment()
}
