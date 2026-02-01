import SwiftUI

struct TutorialsDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct TutorialsView: View {
    
    @State var presenter: TutorialsPresenter
    let delegate: TutorialsDelegate
    
    var body: some View {
        List {
            Section {
                Text("Hello, World!")
            } header: {
                Text("Reset Tutorials")
            }
        }
        .navigationTitle("Tutorials")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Text("Reset Tutorials")
                .callToActionButton(isPrimaryAction: true)
                .anyButton {
                    presenter.onResetTutorialsPressed()
                }
                .padding(.horizontal)
        }
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
    let delegate = TutorialsDelegate()
    
    return RouterView { router in
        builder.tutorialsView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func tutorialsView(router: AnyRouter, delegate: TutorialsDelegate) -> some View {
        TutorialsView(
            presenter: TutorialsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showTutorialsView(delegate: TutorialsDelegate) {
        router.showScreen(.push) { router in
            builder.tutorialsView(router: router, delegate: delegate)
        }
    }
    
}
