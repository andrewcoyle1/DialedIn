import SwiftUI

struct FoodLogSettingsDelegate {
    
}

struct FoodLogSettingsView: View {
    
    @State var presenter: FoodLogSettingsPresenter
    let delegate: FoodLogSettingsDelegate
    
    var body: some View {
        List {
            Section {
                Text("Hello, World!")
            } header: {
                Text("Nutrient Reporting")
            }

            Section {
                Text("Hello, World!")
            } header: {
                Text("Timeline Options")
            }

            Section {
                Text("Hello, World!")
            } header: {
                Text("Food Search")
            }

            Section {
                Text("Hello, World!")
            } header: {
                Text("Food Tiles")
            }

            Section {
                Text("Hello, World!")
            } header: {
                Text("Logger Options")
            }
        }
        .navigationTitle("Food Log")
        .navigationBarTitleDisplayMode(.inline)
            .screenAppearAnalytics(name: "FoodLogSettingsView")
    }
}

extension CoreBuilder {
    
    func foodLogSettingsView(router: Router, delegate: FoodLogSettingsDelegate) -> some View {
        FoodLogSettingsView(
            presenter: FoodLogSettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showFoodLogSettingsView(delegate: FoodLogSettingsDelegate) {
        router.showScreen(.push) { router in
            builder.foodLogSettingsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = FoodLogSettingsDelegate()
    
    return RouterView { router in
        builder.foodLogSettingsView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
