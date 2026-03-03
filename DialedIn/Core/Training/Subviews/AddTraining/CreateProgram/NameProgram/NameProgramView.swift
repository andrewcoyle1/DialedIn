import SwiftUI

struct NameProgramDelegate {
    let onComplete: (@Sendable () -> Void)?
    
    init(onComplete: (@Sendable () -> Void)? = nil) {
        self.onComplete = onComplete
    }
}

struct NameProgramView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: NameProgramPresenter
    let delegate: NameProgramDelegate
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("What would you like to name this program?")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            Text("Name")
            TextField(text: $presenter.programName) {
                Text("")
            }
            .textFieldStyle(.roundedBorder)
            
            Spacer()
        }
        .padding(.horizontal)
        .background(colorScheme.backgroundSecondary)
        .navigationTitle("Create Program")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
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
            .disabled(!presenter.canSave)
            .padding(.horizontal)
        }
    }
}

extension CoreBuilder {
    
    func nameProgramView(router: AnyRouter, delegate: NameProgramDelegate) -> some View {
        NameProgramView(
            presenter: NameProgramPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showNameProgramView(delegate: NameProgramDelegate) {
        router.showScreen(.push) { router in
            builder.nameProgramView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = NameProgramDelegate()
    
    RouterView { router in
        builder.nameProgramView(router: router, delegate: delegate)
    }
    
}
