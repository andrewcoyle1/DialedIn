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
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = ScaleWeightDelegate()
    
    return RouterView { router in
        builder.scaleWeightView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

extension CoreBuilder {
    
    func scaleWeightView(router: Router, delegate: ScaleWeightDelegate) -> some View {
        MetricDetailView(
            presenter: ScaleWeightPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
}

extension CoreRouter {
    
    func showScaleWeightView(delegate: ScaleWeightDelegate) {
        router.showScreen(.sheet) { router in
            builder.scaleWeightView(router: router, delegate: delegate)
        }
    }
    
}
