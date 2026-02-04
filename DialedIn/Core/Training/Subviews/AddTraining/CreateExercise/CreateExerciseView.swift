//
//  CreateExerciseView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
import SwiftfulRouting

struct CreateExerciseView: View {

    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: CreateExercisePresenter

    var body: some View {
        
        List {
            nameSection
            trackableMetricSection
            typeSection
            lateralitySection
        }
        .navigationBarTitle("Create Custom Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .screenAppearAnalytics(name: "CreateExerciseView")
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            Text("Next")
                .callToActionButton(isPrimaryAction: true)
                .padding(.horizontal)
                .anyButton(.press) {
                    presenter.onNextPressed()
                }
                .opacity(presenter.canSave ? 1 : 0.3)
                .disabled(!presenter.canSave)
        }
    }

    private var nameSection: some View {
        Section {
            TextField("Add name", text: Binding(
                get: { presenter.exerciseName ?? "" },
                set: { newValue in
                    presenter.exerciseName = newValue.isEmpty ? nil : newValue
                }
            ))
            .textInputAutocapitalization(.words)
       } header: {
            HStack(alignment: .firstTextBaseline) {
                Text("Exercise Name")
                Spacer()
                Text("Required")
                    .font(.caption)
            }
        }
    }
    
    private var trackableMetricSection: some View {
        Section {
            HStack(spacing: 0) {
                CustomPickerView(
                    text: presenter.trackableMetricA?.name ?? "None",
                    isHighlighted: presenter.trackableMetricA == nil,
                    action: {
                        presenter.trackableMetricPressed(
                            navigationTitle: "Trackable Metric 1",
                            metric: $presenter.trackableMetricA
                        )
                    }
                )
                Divider()
                CustomPickerView(
                    text: presenter.trackableMetricB?.name ?? "None",
                    isHighlighted: presenter.trackableMetricB == nil,
                    action: {
                        presenter.trackableMetricPressed(
                            navigationTitle: "Trackable Metric 2",
                            metric: $presenter.trackableMetricB
                        )
                    }
                )
            }
            .removeListRowFormatting()
        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text("Trackable Metric")
                Spacer()
                Text("Required")
                    .font(.caption)
            }
        }
    }
    
    private var typeSection: some View {
        Section {
            CustomPickerView(
                text: presenter.exerciseType?.name ?? "None",
                isHighlighted: presenter.exerciseType == nil,
                action: {
                    presenter.exerciseTypePressed(
                        navigationTitle: "Exercise Type",
                        type: $presenter.exerciseType
                    )
                }
            )
            .removeListRowFormatting()
        } header: {
            Text("Type")
        }
    }

    private var lateralitySection: some View {
        Section {
            CustomPickerView(
                text: presenter.laterality?.name ?? "None",
                isHighlighted: presenter.laterality == nil,
                action: {
                    presenter.lateralityPressed(
                        navigationTitle: "Laterality",
                        item: $presenter.laterality
                    )
                }
            )
            .removeListRowFormatting()
        } header: {
            Text("Laterality")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onCancelPressed()
            } label: {
                Image(systemName: "xmark")
            }
        }
        
        #if DEBUG || MOCK
        ToolbarSpacer(.fixed, placement: .topBarLeading)
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        
    }
}

extension CoreBuilder {
    func createExerciseView(router: AnyRouter) -> some View {
        CreateExerciseView(
            presenter: CreateExercisePresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showCreateExerciseView() {
        router.showScreen(.fullScreenCover) { router in
            builder.createExerciseView(router: router)
        }
    }
}

#Preview("As sheet") {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.createExerciseView(router: router)
    }
    .previewEnvironment()
}

#Preview("Is saving") {
    @Previewable @State var isPresented: Bool = true
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.createExerciseView(router: router)
    }
    .previewEnvironment()
}

#Preview("As fullscreen cover") {
    @Previewable @State var isPresented: Bool = true
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.createExerciseView(router: router)
    }
    .previewEnvironment()
}

struct CustomPickerView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var text: String
    var isHighlighted: Bool
    var action: () -> Void
    
    var body: some View {
        HStack {
            Text(text)
                .lineLimit(1)
            Spacer()
            Image(systemName: "chevron.down")
        }
        .foregroundStyle(isHighlighted ? .secondary : .primary)
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            Color(colorScheme.backgroundPrimary)
        }
        .anyButton {
            action()
        }
    }
}
