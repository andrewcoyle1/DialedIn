import SwiftUI

struct ProgramIconDelegate {
    var name: String
}

struct ProgramIconView: View {
    
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
        .navigationTitle("Create Program")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "ProgramIconView")
        .toolbar {
            toolbarContent
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarSpacer(.flexible, placement: .bottomBar)
        
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.onNextPressed(name: delegate.name)
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }
}

extension CoreBuilder {
    func programIconView(router: Router, delegate: ProgramIconDelegate) -> some View {
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
    .previewEnvironment()
}
