//
//  LogWeightView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI

struct LogWeightView: View {

    @State var presenter: LogWeightPresenter
    
    var body: some View {
        List {
            dateSection
                .removeListRowFormatting()
            WeightPickerInput(
                unit: $presenter.unit,
                selectedKilograms: $presenter.selectedKilograms,
                selectedPounds: $presenter.selectedPounds
            )
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
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    RouterView { router in
        builder.logWeightView(router: router)
    }
    
}
