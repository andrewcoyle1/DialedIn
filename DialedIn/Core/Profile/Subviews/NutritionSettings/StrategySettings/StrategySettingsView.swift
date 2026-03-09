import SwiftUI

struct StrategySettingsDelegate {
    
}

struct StrategySettingsView: View {
    
    @State var presenter: StrategySettingsPresenter
    let delegate: StrategySettingsDelegate
    
    var body: some View {
        List {
            Section {
                CustomLabelButtonView(
                    symbolName: "calendar",
                    title: "Check-in Day",
                    subtitle: "Monday") {
                        Text("Edit")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {
                                presenter.onEditCheckInDayPressed()
                            }
                    }
                CustomToggleView(
                    symbolName: "hare",
                    title: "Fast Check-in",
                    subtitle: "Off",
                    bool: $presenter.fastCheckInEnabled
                )
            } header: {
                Text("General")
            }

            Section {
                Label("Introduction", systemImage: "info")
                CustomToggleView(
                    title: "Partial Logging",
                    subtitle: nil,
                    bool: $presenter.partialLoggingEnabled
                )
                CustomToggleView(
                    title: "Weigh-In",
                    subtitle: nil,
                    bool: $presenter.weighInEnabled
                )
                CustomToggleView(
                    title: "Fasting",
                    subtitle: nil,
                    bool: $presenter.fastingEnabled
                )
                CustomToggleView(
                    title: "Logging Break",
                    subtitle: nil,
                    bool: $presenter.loggingBreakEnabled
                )
                Label("Program Update", systemImage: "star.fill")
            } header: {
                Text("Coaching Modules")
            } footer: {
                Text("Individually configure which modules can appear during your check in.")
            }
        }
        .navigationTitle("Strategy")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
    }
}

extension CoreBuilder {
    
    func strategySettingsView(router: AnyRouter, delegate: StrategySettingsDelegate) -> some View {
        StrategySettingsView(
            presenter: StrategySettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showStrategySettingsView(delegate: StrategySettingsDelegate) {
        router.showScreen(.push) { router in
            builder.strategySettingsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = StrategySettingsDelegate()
    
    return RouterView { router in
        builder.strategySettingsView(router: router, delegate: delegate)
    }
    
}
