//
//  FoodLoggingConsistencyView.swift
//  DialedIn
//

import SwiftUI

struct FoodLoggingConsistencyDelegate {}

struct FoodLoggingConsistencyView: View {
    @State var presenter: FoodLoggingConsistencyPresenter
    let delegate: FoodLoggingConsistencyDelegate

    var body: some View {
        MetricDetailView(presenter: presenter)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    let delegate = FoodLoggingConsistencyDelegate()

    return RouterView { router in
        builder.foodLoggingConsistencyView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}

extension CoreBuilder {
    func foodLoggingConsistencyView(router: Router, delegate: FoodLoggingConsistencyDelegate, themeColor: Color? = nil) -> some View {
        MetricDetailView(
            presenter: FoodLoggingConsistencyPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            themeColor: themeColor
        )
    }
}

extension CoreRouter {
    func showFoodLoggingConsistencyView(delegate: FoodLoggingConsistencyDelegate, themeColor: Color? = nil) {
        router.showScreen(.sheet) { router in
            builder.foodLoggingConsistencyView(router: router, delegate: delegate, themeColor: themeColor)
        }
    }
}
