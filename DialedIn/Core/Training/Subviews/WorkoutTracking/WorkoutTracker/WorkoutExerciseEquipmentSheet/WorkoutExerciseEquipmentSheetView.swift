//
//  WorkoutExerciseEquipmentSheetView.swift
//  DialedIn
//
//  Sheet that displays choosable equipment for an exercise and highlights currently chosen equipment.
//

import SwiftUI

struct WorkoutExerciseEquipmentSheetDelegate {
    let exercise: WorkoutExerciseModel
    let onSelect: ([EquipmentRef], [EquipmentRef]) -> Void
}

struct WorkoutExerciseEquipmentSheetView: View {
    
    @State var presenter: WorkoutExerciseEquipmentSheetPresenter
    let delegate: WorkoutExerciseEquipmentSheetDelegate

    var body: some View {
        Group {
            if presenter.isLoading {
                ProgressView("Loading equipment...")
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
                    if !presenter.choosableResistance.isEmpty {
                        Section("Resistance") {
                            ForEach(presenter.choosableResistance, id: \.ref) { item in
                                equipmentRow(item: item, isChosen: presenter.chosenResistance.contains(item.ref)) {
                                    presenter.toggleResistance(ref: item.ref)
                                }
                            }
                        }
                    }
                    if !presenter.choosableSupport.isEmpty {
                        Section("Support") {
                            ForEach(presenter.choosableSupport, id: \.ref) { item in
                                equipmentRow(item: item, isChosen: presenter.chosenSupport.contains(item.ref)) {
                                    presenter.toggleSupport(ref: item.ref)
                                }
                            }
                        }
                    }
                    if presenter.choosableResistance.isEmpty && presenter.choosableSupport.isEmpty {
                        Section {
                            Text("No equipment options for this exercise.")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(delegate.exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    presenter.onCancelPressed()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    presenter.onDonePressed(onSelect: delegate.onSelect)
                }
            }
        }

        .task(id: delegate.exercise.templateId) {
            await presenter.loadChoosableEquipment(exerciseTemplateId: delegate.exercise.templateId)
        }
        .onAppear {
            presenter.chosenResistance = delegate.exercise.chosenResistanceEquipment
            presenter.chosenSupport = delegate.exercise.chosenSupportEquipment
        }
    }

    private func equipmentRow(item: AnyEquipment, isChosen: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack {
                if let imageName = item.imageName {
                    ImageLoaderView(urlString: imageName)
                        .frame(width: 40, height: 40)
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .cornerRadius(8)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.body)
                        .foregroundStyle(.primary)
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
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    let delegate = WorkoutExerciseEquipmentSheetDelegate(exercise: .mock) { _, _ in
        
    }
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
