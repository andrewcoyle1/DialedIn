import SwiftUI

struct ExerciseAnalyticsDelegate {
    
}

struct ExerciseAnalyticsView: View {

    @State var presenter: ExerciseAnalyticsPresenter
    let delegate: ExerciseAnalyticsDelegate

    var body: some View {
        List {
            Section {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(presenter.exerciseCards) { item in
                        DashboardCard(
                            title: item.name,
                            subtitle: "Last 7 Days",
                            subsubtitle: item.latest1RM > 0 ? item.latest1RM.formatted(.number.precision(.fractionLength(1))) : "--",
                            subsubsubtitle: "kg",
                            chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
                        ) {
                            SetsBarChart(data: item.last7DaysData, color: .blue)
                        }
                        .tappableBackground()
                        .anyButton(.press) {
                            presenter.onExercisePressed(templateId: item.templateId, name: item.name)
                        }
                    }
                }
                .padding(.horizontal)
                .removeListRowFormatting()
            } header: {
                Text("Exercises")
            }
            .listSectionMargins(.horizontal, 0)
            .listRowSeparator(.hidden)
        }
        .onFirstTask {
            await presenter.loadData()
        }
        .navigationTitle("Exercises")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "ExerciseAnalyticsView")
        .scrollIndicators(.hidden)
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
    
    func exerciseAnalyticsView(router: Router, delegate: ExerciseAnalyticsDelegate) -> some View {
        ExerciseAnalyticsView(
            presenter: ExerciseAnalyticsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showExerciseAnalyticsView(delegate: ExerciseAnalyticsDelegate) {
        router.showScreen(.sheet) { router in
            builder.exerciseAnalyticsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = ExerciseAnalyticsDelegate()
    
    return RouterView { router in
        builder.exerciseAnalyticsView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
