import SwiftUI

struct CreateGymProfileDelegate {
    let onComplete: (() -> Void)?
    var eventParameters: [String: Any]? {
        nil
    }
    
    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
    }
}

struct CreateGymProfileView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: CreateGymProfilePresenter
    let delegate: CreateGymProfileDelegate
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("What would you like to name this gym?")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            Text("Name")
            TextField(text: $presenter.gymProfileName) {
                Text("")
            }
            .textFieldStyle(.roundedBorder)
            
            Spacer()
        }
        .padding(.horizontal)
        .background(colorScheme.backgroundSecondary)
        .navigationTitle("Create Gym Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
        .safeAreaInset(edge: .bottom) {
            CallToActionButton {
                presenter.onContinuePressed(oldDelegate: delegate)
            } label: {
                Text("Continue")
            }
            .disabled(!presenter.canSave)
            .padding(.bottom)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = CreateGymProfileDelegate()
    
    return RouterView { router in
        builder.createGymProfileView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func createGymProfileView(router: AnyRouter, delegate: CreateGymProfileDelegate) -> some View {
        CreateGymProfileView(
            presenter: CreateGymProfilePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showCreateGymProfileView(delegate: CreateGymProfileDelegate) {
        router.showScreen(.push) { router in
            builder.createGymProfileView(router: router, delegate: delegate)
        }
    }
    
}
