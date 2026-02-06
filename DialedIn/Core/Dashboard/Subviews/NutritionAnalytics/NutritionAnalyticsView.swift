import SwiftUI

struct NutritionAnalyticsDelegate {
    
}

struct NutritionAnalyticsView: View {
    
    @State var presenter: NutritionAnalyticsPresenter
    let delegate: NutritionAnalyticsDelegate
    
    var body: some View {
        Text("Hello, World!")
            .screenAppearAnalytics(name: "NutritionAnalyticsView")
    }
}

extension CoreBuilder {
    
    func nutritionAnalyticsView(router: Router, delegate: NutritionAnalyticsDelegate) -> some View {
        NutritionAnalyticsView(
            presenter: NutritionAnalyticsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showNutritionAnalyticsView(delegate: NutritionAnalyticsDelegate) {
        router.showScreen(.push) { router in
            builder.nutritionAnalyticsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = NutritionAnalyticsDelegate()
    
    return RouterView { router in
        builder.nutritionAnalyticsView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
