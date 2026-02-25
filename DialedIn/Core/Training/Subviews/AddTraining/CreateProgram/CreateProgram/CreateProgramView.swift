import SwiftUI

struct CreateProgramDelegate {
    let onDismiss: (() -> Void)?
    let onComplete: (() -> Void)?
    
    init(onDismiss: (() -> Void)? = nil, onComplete: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
        self.onComplete = onComplete
    }
}

struct CreateProgramView: View {
    
    @State var presenter: CreateProgramPresenter
    let delegate: CreateProgramDelegate
    
    var body: some View {
        VStack(spacing: 0) {
            ImageLoaderView()
                .ignoresSafeArea()
                .frame(maxHeight: 400)
            VStack(alignment: .leading) {
                Text("Create Program")
                    .font(.title)
                    .fontWeight(.bold)
                Text("It's time to create a custom workout program.")
            }
            .padding(.top)
            .frame(maxWidth: .infinity)
            Spacer()
        }
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                presenter.onNextPressed(delegate: delegate)
            } label: {
                Text("Continue")
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .padding(.horizontal)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        if delegate.onDismiss != nil {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    presenter.onDismissPressed()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}

extension CoreBuilder {
    
    func createProgramView(router: AnyRouter, delegate: CreateProgramDelegate) -> some View {
        CreateProgramView(
            presenter: CreateProgramPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    
    func showCreateProgramView(delegate: CreateProgramDelegate) {
        router.showScreen(.fullScreenCover) { router in
            builder.createProgramView(router: router, delegate: delegate)
        }
    }
    
    func showOnboardingTrainingProgramView(delegate: CreateProgramDelegate) {
        router.showScreen(.push) { router in
            builder.createProgramView(router: router, delegate: delegate)
        }
    }

}

#Preview("Sheet presentations") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CreateProgramDelegate(onDismiss: { print("dismissed") })
    
    return RouterView { router in
        builder.createProgramView(router: router, delegate: delegate)
    }
    
}

#Preview("Onboarding presentations") {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CreateProgramDelegate()
    
    return RouterView { router in
        builder.createProgramView(router: router, delegate: delegate)
    }
    
}
