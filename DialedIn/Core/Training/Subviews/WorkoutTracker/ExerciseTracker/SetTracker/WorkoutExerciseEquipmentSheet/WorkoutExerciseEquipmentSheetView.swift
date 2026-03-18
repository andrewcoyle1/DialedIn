//
//  WorkoutExerciseEquipmentSheetView.swift
//  DialedIn
//
//  Sheet that displays equipment variations for an exercise and lets the user pick one.
//

import SwiftUI

struct WorkoutExerciseEquipmentSheetDelegate {
    let exercise: Binding<WorkoutExerciseModel>
    let onSelect: (String?) -> Void
}

struct WorkoutExerciseEquipmentSheetView: View {

    @State var presenter: WorkoutExerciseEquipmentSheetPresenter
    let delegate: WorkoutExerciseEquipmentSheetDelegate

    var body: some View {
        Group {
            if presenter.isLoading {
                ProgressView("Loading variations...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = presenter.loadError {
                VStack(spacing: 12) {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List {
                    Section {
                        ForEach(presenter.variationItems) { item in
                            variationRow(item: item)
                        }
                    }
                    .listSectionMargins(.top, 0)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(delegate.exercise.wrappedValue.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .close) {
                    presenter.onCancelPressed()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    presenter.onDonePressed(onSelect: delegate.onSelect)
                }
            }
        }
        .task {
            await presenter.loadVariations(exercise: delegate.exercise.wrappedValue)
        }
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
    }

    private func variationRow(item: VariationDisplayItem) -> some View {
        let isChosen = presenter.chosenVariationId == item.id
        return Button {
            presenter.onSelectVariation(id: item.id)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.body)
                        .foregroundStyle(.primary)
                    if item.resistanceSummary != "None" {
                        Text("Resistance: \(item.resistanceSummary)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if item.supportSummary != "None" {
                        Text("Support: \(item.supportSummary)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if isChosen {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var exercise: WorkoutExerciseModel = .mock
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))

    let delegate = WorkoutExerciseEquipmentSheetDelegate(exercise: $exercise) { _ in }
    RouterView { router in
        builder.workoutExerciseEquipmentSheetView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    func workoutExerciseEquipmentSheetView(router: AnyRouter, delegate: WorkoutExerciseEquipmentSheetDelegate) -> some View {
        WorkoutExerciseEquipmentSheetView(
            presenter: WorkoutExerciseEquipmentSheetPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showWorkoutExerciseEquipmentSheetView(delegate: WorkoutExerciseEquipmentSheetDelegate) {
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.4), .medium, .large], dragIndicator: .visible))) { router in
            builder.workoutExerciseEquipmentSheetView(router: router, delegate: delegate)
        }
    }
}
