import SwiftUI

struct ScaleWeightDelegate {
    
}

struct ScaleWeightView: View {
    
    @State var presenter: ScaleWeightPresenter
    let delegate: ScaleWeightDelegate
    
    var body: some View {
        MetricDetailView(presenter: presenter)
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = ScaleWeightDelegate()
    
    return RouterView { router in
        builder.scaleWeightView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

extension CoreBuilder {

    func scaleWeightView(router: Router, delegate: ScaleWeightDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: ScaleWeightPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}

extension CoreRouter {

    func showScaleWeightView(delegate: ScaleWeightDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.scaleWeightView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}
