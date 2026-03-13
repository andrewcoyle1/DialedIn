import SwiftUI

struct LoggerFoodTilesDelegate { }

struct LoggerFoodTilesView: View {

    @State var presenter: LoggerFoodTilesPresenter
    let delegate: LoggerFoodTilesDelegate

    var body: some View {
        List {
            Section {
                CustomToggleView(
                    title: "Show Food Image",
                    subtitle: "Display food image in search result rows",
                    bool: $presenter.showFoodImageInLogger
                )
                CustomToggleView(
                    title: "Show Calories",
                    subtitle: "Display calorie count in search result rows",
                    bool: $presenter.showCaloriesInLogger
                )
                CustomToggleView(
                    title: "Show Macros",
                    subtitle: "Display P/F/C macros in search result rows",
                    bool: $presenter.showMacrosInLogger
                )
                CustomToggleView(
                    title: "Show Portion",
                    subtitle: "Display portion size in search result rows",
                    bool: $presenter.showPortionInLogger
                )
            }
        }
        .navigationTitle("Logger Food Tiles")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear()
        }
    }
}

extension CoreBuilder {

    func loggerFoodTilesView(router: AnyRouter, delegate: LoggerFoodTilesDelegate) -> some View {
        LoggerFoodTilesView(
            presenter: LoggerFoodTilesPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = LoggerFoodTilesDelegate()

    return RouterView { router in
        builder.loggerFoodTilesView(router: router, delegate: delegate)
    }
}
