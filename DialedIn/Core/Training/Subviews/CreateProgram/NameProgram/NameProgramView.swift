import SwiftUI

struct NameProgramDelegate {
    
}

struct NameProgramView: View {
    
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
        .navigationTitle("Create Program")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "NameProgramView")
        .toolbar {
            toolbarContent
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarSpacer(.flexible, placement: .bottomBar)
        
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.onNextPressed()
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(!presenter.canSave)
        }
    }
}

extension CoreBuilder {
    
    func nameProgramView(router: Router, delegate: NameProgramDelegate) -> some View {
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
    
    return RouterView { router in
        builder.nameProgramView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
