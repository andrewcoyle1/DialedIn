import SwiftUI

struct ProgramIconDelegate {
    let onComplete: (@Sendable () -> Void)?
    let name: String

    init(onComplete: (@Sendable () -> Void)? = nil, name: String) {
        self.onComplete = onComplete
        self.name = name
    }
}

struct ProgramIconView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: ProgramIconPresenter
    let delegate: ProgramIconDelegate
    
    var body: some View {
        VStack {
            Text("What icon should we use to display this program?")
                .font(.title2)
                .fontWeight(.bold)

            HStack {
                ForEach(presenter.colours, id: \.self) { colour in
                    ZStack {
                        Circle()
                            .opacity(0.3)
                        Image(systemName: presenter.selectedIcon)
                    }
                    .foregroundStyle(colour)
                    .overlay {
                        Circle()
                            .stroke(colour == presenter.selectedColour ? presenter.selectedColour : Color.clear, lineWidth: 4)
                    }
                    .anyButton {
                        presenter.onColourPressed(colour: colour)
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.vertical)
            
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem(), GridItem(), GridItem()]) {
                ForEach(presenter.icons, id: \.self) { icon in
                    ZStack {
                        Circle()
                            .opacity(0.3)
                            .frame(maxWidth: 40)
                        Image(systemName: icon)
                    }
                    .foregroundStyle(presenter.selectedColour)
                    .padding(.vertical, 4)
                    .overlay {
                        Circle()
                            .stroke(icon == presenter.selectedIcon ? presenter.selectedColour : Color.clear, lineWidth: 4)
                    }
                    .anyButton {
                        presenter.onIconPressed(icon: icon)
                    }

                }
            }
            .padding(.horizontal)
            Spacer()
        }
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
            CallToActionButton {
                presenter.onNextPressed(delegate: delegate)
            } label: {
                Text("Continue")
            }
            .padding(.bottom)
        }
    }
}

extension CoreBuilder {
    func programIconView(router: AnyRouter, delegate: ProgramIconDelegate) -> some View {
        ProgramIconView(
            presenter: ProgramIconPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showProgramIconView(delegate: ProgramIconDelegate) {
        router.showScreen(.push) { router in
            builder.programIconView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = ProgramIconDelegate(name: "Preview Program")
    
    return RouterView { router in
        builder.programIconView(router: router, delegate: delegate)
    }
    
}
