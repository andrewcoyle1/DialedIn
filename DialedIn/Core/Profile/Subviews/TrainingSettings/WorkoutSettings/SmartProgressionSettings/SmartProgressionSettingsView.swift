import SwiftUI

struct SmartProgressionSettingsDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct SmartProgressionSettingsView: View {
    
    @State var presenter: SmartProgressionSettingsPresenter
    let delegate: SmartProgressionSettingsDelegate
    
    var body: some View {
        List {
            Section {
                CustomLabelButtonView(
                    symbolName: "book.pages",
                    title: "Initial log fill",
                    subtitle: "Smart Progression values") {
                        Text("Edit")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {

                            }
                    }
                CustomToggleView(
                    symbolName: "arrow.trianglehead.branch",
                    title: "Apply in session",
                    subtitle: "Allow Smart Progression to fill in new values for exercise data entry fields mid-workout",
                    bool: $presenter.applyInSession
                )
                CustomLabelButtonView(
                    symbolName: "dot.squareshape",
                    title: "Adjustment Mode",
                    subtitle: "Weight-first") {
                        Text("Edit")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {

                            }
                    }
            } header: {
                Text("Behaviour")
            }
        }
        .navigationTitle("Smart Progression")
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
    let delegate = SmartProgressionSettingsDelegate()
    
    return RouterView { router in
        builder.smartProgressionSettingsView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func smartProgressionSettingsView(router: AnyRouter, delegate: SmartProgressionSettingsDelegate) -> some View {
        SmartProgressionSettingsView(
            presenter: SmartProgressionSettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showSmartProgressionSettingsView(delegate: SmartProgressionSettingsDelegate) {
        router.showScreen(.push) { router in
            builder.smartProgressionSettingsView(router: router, delegate: delegate)
        }
    }
    
}
