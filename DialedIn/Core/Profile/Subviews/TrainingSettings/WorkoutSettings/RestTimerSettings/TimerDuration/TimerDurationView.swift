import SwiftUI

struct TimerDurationDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct TimerDurationView: View {

    @State var presenter: TimerDurationPresenter
    let delegate: TimerDurationDelegate

    var body: some View {
        List {
            Section {
                ForEach(ExerciseType.allCases, id: \.self) { type in
                    CustomLabelButtonView(
                        symbolName: "",
                        title: type.name,
                        subtitle: presenter.formattedDuration(for: type)) {
                            Text("Edit")
                                .padding(.horizontal, 8)
                                .padding(8)
                                .background(Color.secondary.opacity(0.2), in: .capsule)
                                .anyButton(.press) {
                                    presenter.onEditPressed(type: type)
                                }
                        }
                }
                CustomLabelButtonView(
                    symbolName: "",
                    title: "Reset Defaults",
                    subtitle: "Reset timers to default settings") {
                        Text("Reset")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {
                                presenter.resetDefaults()
                            }
                    }
            } header: {
                Text("Default Timers")
            }

            Section {
                CustomLabelButtonView(
                    symbolName: "",
                    title: "Add Exercise Timer",
                    subtitle: "Set timers for specific exercises") {
                        Text("Add")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {

                            }
                    }
            } header: {
                Text("Exercise Timers")
            } footer: {
                Text("These take precident over default timers")
            }
        }
        .navigationTitle("Timer Duration")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $presenter.isEditingType) {
            if let type = presenter.editingType {
                durationPicker(for: type)
            }
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }

    // MARK: - Duration Picker Sheet

    @ViewBuilder
    private func durationPicker(for type: ExerciseType) -> some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Picker("Minutes", selection: $presenter.editMinutes) {
                        ForEach(0..<10, id: \.self) { min in
                            Text("\(min) min").tag(min)
                        }
                    }
                    .pickerStyle(.wheel)

                    Picker("Seconds", selection: $presenter.editSeconds) {
                        ForEach([0, 15, 30, 45], id: \.self) { sec in
                            Text("\(sec) sec").tag(sec)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .padding(.horizontal)
            }
            .navigationTitle(type.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presenter.isEditingType = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { presenter.saveEdit() }
                }
            }
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = TimerDurationDelegate()

    return RouterView { router in
        builder.timerDurationView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {

    func timerDurationView(router: AnyRouter, delegate: TimerDurationDelegate) -> some View {
        TimerDurationView(
            presenter: TimerDurationPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {

    func showTimerDurationView(delegate: TimerDurationDelegate) {
        router.showScreen(.push) { router in
            builder.timerDurationView(router: router, delegate: delegate)
        }
    }

}
