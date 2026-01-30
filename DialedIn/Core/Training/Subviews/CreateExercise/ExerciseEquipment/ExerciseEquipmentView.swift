import SwiftUI

struct ExerciseEquipmentDelegate {
    let name: String
    let trackableMetricA: TrackableExerciseMetric
    let trackableMetricB: TrackableExerciseMetric?
    let exerciseType: ExerciseType?
    let laterality: Laterality?
    let muscleGroups: [Muscles: Bool]
}

struct ExerciseEquipmentView: View {
    
    @State var presenter: ExerciseEquipmentPresenter
    let delegate: ExerciseEquipmentDelegate
    
    var body: some View {
        List {
            Section {
                ActionRow(title: "Bodyweight Exercise", subtitle: "This exercise is performed with bodyweight, without additional resistance.") {
                    Toggle(isOn: $presenter.bodyweightExercise) { }
                }

                ActionRow(title: "Resistance", subtitle: presenter.resistanceSubtitle, subsubtitle: presenter.resistanceSubsubtitle) {
                    Text("Add")
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color.secondary.opacity(0.5), in: .capsule)
                        .anyButton(.press) {
                            presenter.onAddResistancePressed()
                        }
                        .disabled(presenter.bodyweightExercise ? true : false)
                }
                .opacity(presenter.bodyweightExercise ? 0.4 : 1)

                ActionRow(title: "Support", subtitle: presenter.supportSubtitle, subsubtitle: presenter.supportSubsubtitle) {
                    Text("Add")
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(Color.secondary.opacity(0.5), in: .capsule)
                        .anyButton(.press) {
                            presenter.onAddSupportPressed()
                        }

                }
            }
            .listSectionMargins(.top, 0)
        }
        .navigationTitle("Select Equipment")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "ExerciseEquipmentView")
        .safeAreaInset(edge: .bottom) {
            Text("Next")
                .callToActionButton(isPrimaryAction: true)
                .padding(.horizontal)
                .anyButton(.press) {
                    presenter.onNextPressed(delegate: delegate)
                }
                .opacity(presenter.canContinue ? 1 : 0.3)
                .disabled(!presenter.canContinue)

        }
    }
}

struct ActionRow<ActionArea: View>: View {
    
    var title: String
    var subtitle: String?
    var subsubtitle: String?
    var actionArea: () -> ActionArea
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let subsubtitle {
                        Text(subsubtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                    }
                }
            }
            Spacer()
            actionArea()
        }
    }
}

extension CoreBuilder {
    
    func exerciseEquipmentView(router: Router, delegate: ExerciseEquipmentDelegate) -> some View {
        ExerciseEquipmentView(
            presenter: ExerciseEquipmentPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showExerciseEquipmentView(delegate: ExerciseEquipmentDelegate) {
        router.showScreen(.push) { router in
            builder.exerciseEquipmentView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = ExerciseEquipmentDelegate(
        name: "Bench Press",
        trackableMetricA: .reps,
        trackableMetricB: .weight,
        exerciseType: .compoundUpper,
        laterality: .bilateral,
        muscleGroups: [:]
    )
    
    return RouterView { router in
        builder.exerciseEquipmentView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
