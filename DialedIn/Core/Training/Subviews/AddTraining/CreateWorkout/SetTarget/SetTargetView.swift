import Foundation
import SwiftUI

struct SetTargetDelegate {
    var exercise: Binding<WorkoutTemplateExercise>
}

struct SetTargetView: View {
    
    @State var presenter: SetTargetPresenter
    
    /// The committed binding from the parent (only written to on save)
    private let committedExercise: Binding<WorkoutTemplateExercise>
    
    /// Local working copy that drives the UI
    @State private var workingExercise: WorkoutTemplateExercise
    
    init(presenter: SetTargetPresenter, delegate: SetTargetDelegate) {
        self.presenter = presenter
        self.committedExercise = delegate.exercise
        self._workingExercise = State(initialValue: delegate.exercise.wrappedValue)
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Set")
                        .frame(width: 40)
                    Text("Reps Min")
                        .frame(maxWidth: .infinity)
                    Text("Reps Max")
                        .frame(maxWidth: .infinity)
                    Text("RIR")
                        .frame(width: 40)
                }
                
                ForEach($workingExercise.setTargets) { $setTarget in
                    HStack {
                        Text("\(setTarget.setNumber)")
                            .padding(8)
                            .background(.secondary.opacity(0.2), in: Circle())
                            .frame(width: 40)

                        TextField("Optional", text: intTextBinding($setTarget.minReps))
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        
                        TextField("Optional", text: intTextBinding($setTarget.maxReps))
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                        
                        Circle()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.secondary.opacity(0.2))
                            .overlay {
                                if let rirTarget = setTarget.rirTarget {
                                    Text("\(rirTarget)")
                                }
                            }
                            .frame(width: 40)

                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            removeSetTarget(setTarget)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .listRowSeparator(.hidden, edges: .bottom)
                    .listRowInsets(.vertical, 0)
                }
                Image(systemName: "plus")
                    .font(.system(size: 16))
                    .padding(4)
                    .background(.secondary.opacity(0.2), in: Circle())
                    .anyButton(.press) {
                        addSetTarget()
                    }
            }
            
            Section {
                Toggle(isOn: $workingExercise.setRestTimers) {
                    VStack(alignment: .leading) {
                        Text("Set Rest Timers")
                            .font(.callout)
                        Text("This will override default exercise settings.")
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Targets")
        .navigationSubtitle(workingExercise.exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "SetTargetView")
        .toolbar {
            toolbarContent
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(role: .close) {
                presenter.onDismissPressed()
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button(role: .confirm) {
                saveAndDismiss()
            }
        }
    }
    
    private func addSetTarget() {
        let count = workingExercise.setTargets.count
        workingExercise.setTargets.append(SetTarget(setNumber: count + 1))
    }
    
    private func removeSetTarget(_ setTarget: SetTarget) {
        workingExercise.setTargets.removeAll { $0.id == setTarget.id }
        // Renumber remaining sets
        for index in workingExercise.setTargets.indices {
            workingExercise.setTargets[index].setNumber = index + 1
        }
    }
    
    private func saveAndDismiss() {
        // Write the entire working copy back to trigger @Observable detection
        committedExercise.wrappedValue = workingExercise
        presenter.onDismissPressed()
    }
    
    private func intTextBinding(_ value: Binding<Int?>) -> Binding<String> {
        Binding(
            get: {
                guard let currentValue = value.wrappedValue else { return "" }
                return String(currentValue)
            },
            set: { newValue in
                let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else {
                    value.wrappedValue = nil
                    return
                }
                value.wrappedValue = Int(trimmed)
            }
        )
    }
}

extension CoreBuilder {
    
    func setTargetView(router: Router, delegate: SetTargetDelegate) -> some View {
        SetTargetView(
            presenter: SetTargetPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showSetTargetView(delegate: SetTargetDelegate) {
        router.showScreen(.sheet) { router in
            builder.setTargetView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    @Previewable @State var exercise: WorkoutTemplateExercise = WorkoutTemplateExercise(exercise: .mock, setRestTimers: false)
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = SetTargetDelegate(exercise: $exercise)
    
    return RouterView { router in
        builder.setTargetView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
