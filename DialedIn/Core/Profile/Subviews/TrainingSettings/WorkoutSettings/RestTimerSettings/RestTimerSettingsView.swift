import SwiftUI

struct RestTimerSettingsDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct RestTimerSettingsView: View {
    
    @State var presenter: RestTimerSettingsPresenter
    let delegate: RestTimerSettingsDelegate
    
    var body: some View {
        List {
            Section {
                CustomLabelButtonView(
                    symbolName: "heart.fill",
                    title: "Timer Duration",
                    subtitle: "Configure rest duration for different exercise types") {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .foregroundStyle(.secondary)
                            .padding()
                            .anyButton(.press) {
                                presenter.onTimerDurationPressed()
                            }
                    }
                CustomToggleView(
                    symbolName: "flag",
                    title: "Rest After Last Warm-Up Set",
                    subtitle: "Use rest timers after the last warm-up set",
                    bool: .constant(true)
                )
                CustomToggleView(
                    symbolName: "checkmark.circle.fill",
                    title: "Rest Between Exercises",
                    subtitle: "Use rest timers when moving between exercises",
                    bool: .constant(true)
                )
                CustomToggleView(
                    symbolName: "signpost.right.and.left.fill",
                    title: "Rest Between Left/Right Sets",
                    subtitle: "Use rest timers in between left and right sets",
                    bool: .constant(true)
                )
            } header: {
                Text("Behaviour")
            }
            
            Section {
                CustomToggleView(
                    symbolName: "timer",
                    title: "Use Rest Timers",
                    subtitle: "Rest timers will count down after each exercise set",
                    bool: .constant(true)
                )
                CustomToggleView(
                    symbolName: "music.note",
                    title: "Play Sound",
                    subtitle: "Play sound when rest time is over",
                    bool: .constant(true)
                )
                CustomToggleView(
                    symbolName: "apple.haptics.and.exclamationmark.triangle",
                    title: "Vibrate",
                    subtitle: "Vibrate when rest time is over",
                    bool: .constant(true)
                )

            } header: {
                Text("Notifications")
            }
            
            Section {
                CustomLabelButtonView(
                    symbolName: "figure.yoga",
                    title: "Rest After Last Warm-Up Set",
                    subtitle: "75%") {
                        Text("Edit")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {

                            }
                    }
                CustomLabelButtonView(
                    symbolName: "checkmark.circle.fill",
                    title: "Rest Between Exercises",
                    subtitle: "100%") {
                        Text("Edit")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {

                            }
                    }
                CustomLabelButtonView(
                    symbolName: "signpost.right.and.left.fill",
                    title: "Rest Between Left/Right Sets",
                    subtitle: "50%") {
                        Text("Edit")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {

                            }
                    }

            } header: {
                Text("Rest Scaling")
            }
        }
        .navigationTitle("Rest Timer")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = RestTimerSettingsDelegate()
    
    return RouterView { router in
        builder.restTimerSettingsView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func restTimerSettingsView(router: AnyRouter, delegate: RestTimerSettingsDelegate) -> some View {
        RestTimerSettingsView(
            presenter: RestTimerSettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showRestTimerSettingsView(delegate: RestTimerSettingsDelegate) {
        router.showScreen(.push) { router in
            builder.restTimerSettingsView(router: router, delegate: delegate)
        }
    }
    
}
