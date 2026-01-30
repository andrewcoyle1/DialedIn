import SwiftUI

struct ExerciseSaveDelegate {

    let exerciseName: String
    let trackableMetricA: TrackableExerciseMetric
    let trackableMetricB: TrackableExerciseMetric?
    var type: ExerciseType?
    let laterality: Laterality?

    let targetMuscles: [Muscles: Bool]

    let isBodyweight: Bool
    let resistanceEquipment: [EquipmentRef]
    let supportEquipment: [EquipmentRef]

    let rangeOfMotion: Int
    let stability: Int

    let bodyweightContribution: Int
    let alternativeNames: [String]
    let exerciseDescription: String

    var eventParameters: [String: Any]? {
        nil
    }

    var trackableMetricString: String {
        if let metricB = self.trackableMetricB {
            return "\(trackableMetricA.name) x \(metricB.name)"
        } else {
            return trackableMetricA.name
        }
    }

    var alternativeNamesConcatenated: String {
        alternativeNames.joined(separator: ", ")
    }
}

struct ExerciseSaveView: View {

    @State var presenter: ExerciseSavePresenter
    let delegate: ExerciseSaveDelegate

    var body: some View {
        List {
            definitionSection
//            nameSection
//            trackableMetricSection
//            if let type = delegate.type {
//                typeSection(type)
//            }
//            if let laterality = delegate.laterality {
//                lateralitySection(laterality)
//            }

            if !delegate.targetMuscles.isEmpty {
                targetMusclesSection
            }

            Section {
                rangeOfMotionSection
                stabilitySection
            }

            resistanceEquipmentSection

            supportEquipmentSection

            detailsSection
        }
        .navigationTitle("Save Exercise")
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                Text("Create & Add")
                    .callToActionButton(isPrimaryAction: true)
                    .padding(.horizontal)
                    .anyButton(.press) {
                        presenter.onCreateAndAddPressed(delegate: delegate)
                    }
                Text("Create")
                    .callToActionButton(isPrimaryAction: false)
                    .padding(.horizontal)
                    .anyButton(.press) {
                        presenter.onCreatePressed(delegate: delegate)
                    }

            }
        }
    }

    private var definitionSection: some View {
        Section {
            HStack(alignment: .firstTextBaseline) {
                Text("Exercise Name: ")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseName)
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Trackable Metric: ")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.trackableMetricString)
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Type: ")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.type?.name ?? "None")
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Laterality: ")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.laterality?.name ?? "None")
            }
        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text("Definition")
                Spacer()
                Text("Final")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var nameSection: some View {
        Section {
            HStack {
                Text("Exercise Name: ")
                    .font(.subheadline)
                Text(delegate.exerciseName)
            }
        } header: {
            HStack {
                Text("Exercise Name")
                Spacer()
                Text("Final")
                    .font(.caption)
            }
        }
    }

    private var trackableMetricSection: some View {
        Section {
            TextField("Trackable Metric", text: .constant(delegate.trackableMetricString))
                .disabled(true)
        } header: {
            HStack {
                Text("Trackable Metric")
                Spacer()
                Text("Final")
                    .font(.caption)
            }
        }
    }

    private func typeSection(_ type: ExerciseType) -> some View {
        Section {
            TextField("Type", text: .constant(type.name))
                .disabled(true)
        } header: {
            HStack {
                Text("Type")
                Spacer()
                Text("Final")
                    .font(.caption)
            }
        }
    }

    private func lateralitySection(_ laterality: Laterality) -> some View {
        Section {
            TextField("Laterality", text: .constant(laterality.name))
                .disabled(true)
        } header: {
            HStack {
                Text("Laterality")
                Spacer()
                Text("Final")
                    .font(.caption)
            }
        }
    }

    private var targetMusclesSection: some View {
        let muscles = Array(delegate.targetMuscles).sorted { $0.key.name < $1.key.name }
        return Section {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(muscles, id: \.key) { muscle, isPrimary in
                        Text("\(muscle.name): \(isPrimary ? "Primary" : "Secondary")")
                    }
                }
            }
            .scrollIndicators(.hidden)
        } header: {
            HStack {
                Text("Target Muscles")
                Spacer()
                Text("Final")
                    .font(.caption)
            }
        }
    }

    private var rangeOfMotionSection: some View {
        HStack {
            Text("Range of Motion")
            Spacer()
            HStack {
                ForEach(1...5) { value in
                    Capsule()
                        .fill(value <= delegate.rangeOfMotion ? Color.accentColor : Color.secondary.opacity(0.2))
                }
            }
            .frame(maxWidth: 200)
        }
    }

    private var stabilitySection: some View {
        HStack {
            Text("Stability")
            Spacer()
            HStack {
                ForEach(1...5) { value in
                    Capsule()
                        .fill(value <= delegate.stability ? Color.accentColor : Color.secondary.opacity(0.2))
                }
            }
            .frame(maxWidth: 200)
        }
    }

    private var resistanceEquipmentSection: some View {
        Section {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(delegate.resistanceEquipment, id: \.self) { equipment in
                        VStack {
                            ImageLoaderView()
                                .frame(height: 200)
                            Text(equipment.equipmentId)
                        }
                    }

                }
            }
        } header: {
            HStack {
                Text("Resistance Equipment")
                Spacer()
                Text("Final")
                    .font(.caption)
            }
        }
    }

    private var supportEquipmentSection: some View {
        Section {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(delegate.supportEquipment, id: \.self) { equipment in
                        VStack {
                            ImageLoaderView()
                                .frame(height: 200)
                            Text(equipment.equipmentId)
                        }
                    }
                }
            }
        } header: {
            HStack {
                Text("Support Equipment")
                Spacer()
                Text("Final")
                    .font(.caption)
            }
        }
    }

    private var detailsSection: some View {
        Section {
            HStack(alignment: .firstTextBaseline) {
                Text("Body Weight Contribution: ")
                    .fontWeight(.semibold)
                Spacer()
                Text("\(delegate.bodyweightContribution)%")
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Alternative Names: ")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.alternativeNamesConcatenated)
                    .lineLimit(2)
            }
            HStack(alignment: .firstTextBaseline) {
                Text("Description: ")
                    .fontWeight(.semibold)
                Spacer()
                Text(delegate.exerciseDescription)
                    .lineLimit(2)

            }

        } header: {
            Text("Details")
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = ExerciseSaveDelegate(
        exerciseName: "Bench Press",
        trackableMetricA: .reps,
        trackableMetricB: .weight,
        type: .compoundUpper,
        laterality: .bilateral,
        targetMuscles: [
            .chest: false,
            .frontDelts: true,
            .triceps: true
        ],
        isBodyweight: false, 
        resistanceEquipment: [],
        supportEquipment: [],
        rangeOfMotion: 4,
        stability: 5,
        bodyweightContribution: 75,
        alternativeNames: [],
        exerciseDescription: ""
    )

    return RouterView { router in
        builder.exerciseSaveView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func exerciseSaveView(router: AnyRouter, delegate: ExerciseSaveDelegate) -> some View {
        ExerciseSaveView(
            presenter: ExerciseSavePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showExerciseSaveView(delegate: ExerciseSaveDelegate) {
        router.showScreen(.push) { router in
            builder.exerciseSaveView(router: router, delegate: delegate)
        }
    }
    
}
