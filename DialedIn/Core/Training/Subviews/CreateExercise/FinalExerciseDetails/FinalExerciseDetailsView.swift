import SwiftUI

struct FinalExerciseDetailsDelegate {
    let name: String
    let trackableMetricA: TrackableExerciseMetric
    let trackableMetricB: TrackableExerciseMetric?
    let exerciseType: ExerciseType?
    let laterality: Laterality?
    let targetMuscles: [Muscles: Bool]

    let isBodyweight: Bool
    let resistanceEquipment: [EquipmentRef]
    let supportEquipment: [EquipmentRef]

    var eventParameters: [String: Any]? {
        nil
    }
}

struct FinalExerciseDetailsView: View {
    
    @State var presenter: FinalExerciseDetailsPresenter
    let delegate: FinalExerciseDetailsDelegate

    var body: some View {
        List {
            rangeOfMotionSection
                .listSectionMargins(.top, 0)
            stabilitySection

            bodyweightSection

            alternateNamesSection

            descriptionSection
        }
        .navigationTitle("Final Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
        .safeAreaInset(edge: .bottom) {
            Text("Next")
                .callToActionButton(isPrimaryAction: true)
                .padding(.horizontal)
                .anyButton(.press) {
                    presenter.onNextPressed(delegate: delegate)
                }
        }
    }

    private var rangeOfMotionSection: some View {
        Stepper(value: $presenter.rangeOfMotion, in: 0...5) {
            VStack(alignment: .leading) {
                Text("Range of Motion")
                Spacer()
                HStack {
                    ForEach(1...5) { value in
                        Capsule()
                            .fill(value <= presenter.rangeOfMotion ? Color.accentColor : Color.secondary.opacity(0.2))
                    }
                }
                .frame(maxWidth: 200)
            }
        }

    }

    private var stabilitySection: some View {
        Stepper(value: $presenter.stability, in: 0...5) {
            VStack(alignment: .leading) {
                Text("Stability")
                Spacer()
                HStack {
                    ForEach(1...5) { value in
                        Capsule()
                            .fill(value <= presenter.stability ? Color.accentColor : Color.secondary.opacity(0.2))
                    }
                }
                .frame(maxWidth: 200)
            }
        }
    }

    private var bodyweightSection: some View {
        Section {
            HStack {
                TextField("", value: $presenter.bodyweightContribution, format: .number)
                    .keyboardType(.numberPad)
                Text("%")
                    .foregroundStyle(.secondary)
            }
        } header: {
            HStack {
                Text("Body Weight Contribution")
                Spacer()
                Text("Required")
                    .font(.caption)
            }
        } footer: {
            Text("XX kg at your current weight.")
        }
    }

    private var alternateNamesSection: some View {
        Section {
            TextField(text: $presenter.alternateNames, prompt: Text("Optionally add other names")) {
                Text("Alternate Names")
            }
            .lineLimit(2)
        } header: {
            HStack {
                Text("Alternate Names")
                Spacer()
                Text("\(presenter.alternateNames.count)/300")
                    .font(.caption)
            }
        } footer: {
            Text("Separate names with a comma.")
        }
    }

    private var descriptionSection: some View {
        Section {
            HStack {
                Text(presenter.exerciseDescription)
                    .lineLimit(2)
                Text("Edit")
                    .padding(2)
                    .padding(.horizontal, 4)
                    .background(.secondary, in: Capsule())
            }
        } header: {
            Text("Description")
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = FinalExerciseDetailsDelegate(
        name: "Bench Press",
        trackableMetricA: .reps,
        trackableMetricB: .weight,
        exerciseType: .compoundUpper,
        laterality: .bilateral,
        targetMuscles: [.chest: false, .frontDelts: true, .triceps: true],
        isBodyweight: false, 
        resistanceEquipment: [],
        supportEquipment: []
    )

    return RouterView { router in
        builder.finalExerciseDetailsView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func finalExerciseDetailsView(router: AnyRouter, delegate: FinalExerciseDetailsDelegate) -> some View {
        FinalExerciseDetailsView(
            presenter: FinalExerciseDetailsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showFinalExerciseDetailsView(delegate: FinalExerciseDetailsDelegate) {
        router.showScreen(.push) { router in
            builder.finalExerciseDetailsView(router: router, delegate: delegate)
        }
    }
    
}
