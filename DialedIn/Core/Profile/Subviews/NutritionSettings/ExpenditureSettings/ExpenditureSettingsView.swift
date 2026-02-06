import SwiftUI

struct ExpenditureSettingsDelegate {
    
}

struct ExpenditureSettingsView: View {
    
    @State var presenter: ExpenditureSettingsPresenter
    let delegate: ExpenditureSettingsDelegate
    
    var body: some View {
        List {
            Section {
                Text("Hello, World!")
            } header: {
                Text("Initial Estimate")
            }

            Section {
                Text("Hello, World!")
            } header: {
                Text("Expenditure Calculation")
            }

            Section {
                Text("Hello, World!")
            } header: {
                Text("Expenditure Modifiers")
            }
        }
        .navigationTitle("Expenditure")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "ExpenditureSettingsView")
    }
}

extension CoreBuilder {
    
    func expenditureSettingsView(router: Router, delegate: ExpenditureSettingsDelegate) -> some View {
        ExpenditureSettingsView(
            presenter: ExpenditureSettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showExpenditureSettingsView(delegate: ExpenditureSettingsDelegate) {
        router.showScreen(.push) { router in
            builder.expenditureSettingsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = ExpenditureSettingsDelegate()
    
    return RouterView { router in
        builder.expenditureSettingsView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
