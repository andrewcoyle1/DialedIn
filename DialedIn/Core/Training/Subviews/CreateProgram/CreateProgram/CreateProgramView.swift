import SwiftUI

struct CreateProgramDelegate {
    
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
        .screenAppearAnalytics(name: "CreateProgramView")
        .toolbar {
            toolbarContent
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button {
                presenter.onDismissPressed()
            } label: {
                Image(systemName: "xmark")
            }
        }
        
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.onNextPressed()
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }
}

extension CoreBuilder {
    
    func createProgramView(router: Router, delegate: CreateProgramDelegate) -> some View {
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
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CreateProgramDelegate()
    
    return RouterView { router in
        builder.createProgramView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
