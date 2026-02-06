import SwiftUI

struct InsightsAndAnalyticsDelegate {
    
}

struct InsightsAndAnalyticsView: View {
    
    @State var presenter: InsightsAndAnalyticsPresenter
    let delegate: InsightsAndAnalyticsDelegate
    
    var body: some View {
        List {
            Section {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    DashboardCard(title: "Workouts", subtitle: "Last 7 Workouts", subsubtitle: "12", subsubsubtitle: "sets")
                        .tappableBackground()
                        .anyButton(.press) {
                            
                        }
                    DashboardCard(title: "Expenditure", subtitle: "Last 7 Days", subsubtitle: "2993", subsubsubtitle: "kcal")
                        .tappableBackground()
                        .anyButton(.press) {
                            
                        }
                    DashboardCard(title: "Weight Trend", subtitle: "Last 7 Days", subsubtitle: "83.2", subsubsubtitle: "kg")
                        .tappableBackground()
                        .anyButton(.press) {
                            
                        }
                    DashboardCard(title: "Energy Balance", subtitle: "Last 7 Days", subsubtitle: "1696", subsubsubtitle: "kcal deficit")
                        .tappableBackground()
                        .anyButton(.press) {
                            
                        }
                    DashboardCard(title: "Goal Progress", subtitle: "Last 4 Days", subsubtitle: "7", subsubsubtitle: "%")
                        .tappableBackground()
                        .anyButton(.press) {
                            
                        }
                }
                .padding(.horizontal, 8)
                .removeListRowFormatting()
            }
        }
        .navigationTitle("Insights & Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "InsightsAndAnalyticsView")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .close) {
                    presenter.onDismissPressed()
                }
            }
        }
    }
}

extension CoreBuilder {
    
    func insightsAndAnalyticsView(router: Router, delegate: InsightsAndAnalyticsDelegate) -> some View {
        InsightsAndAnalyticsView(
            presenter: InsightsAndAnalyticsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showInsightsAndAnalyticsView(delegate: InsightsAndAnalyticsDelegate) {
        router.showScreen(.sheet) { router in
            builder.insightsAndAnalyticsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = InsightsAndAnalyticsDelegate()
    
    return RouterView { router in
        builder.insightsAndAnalyticsView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
