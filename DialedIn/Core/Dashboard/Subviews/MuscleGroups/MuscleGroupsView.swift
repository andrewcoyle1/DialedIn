import SwiftUI

struct MuscleGroupsDelegate {
    
}

struct MuscleGroupsView: View {
    
    @State var presenter: MuscleGroupsPresenter
    let delegate: MuscleGroupsDelegate
    
    var body: some View {
        List {
            Group {
                Section {
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(presenter.upperMuscles, id: \.self) { muscle in
                            muscleCard(muscle: muscle)
                        }
                    }
                    .padding(.horizontal)
                    .removeListRowFormatting()
                    
                } header: {
                    Text("Upper")
                }
                
                Section {
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        ForEach(presenter.lowerMuscles, id: \.self) { muscle in
                            muscleCard(muscle: muscle)
                        }
                    }
                    .padding(.horizontal)
                    .removeListRowFormatting()
                    
                } header: {
                    Text("Lower")
                }
            }
            .listSectionMargins(.horizontal, 0)
            .listRowSeparator(.hidden)
        }
        .onFirstTask {
            await presenter.loadData()
        }
        .navigationTitle("Muscle Groups")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "MuscleGroupsView")
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .close) {
                    presenter.onDismissPressed()
                }
            }
        }
    }
    
    @ViewBuilder
    private func muscleCard(muscle: Muscles) -> some View {
        let data = presenter.setsData(for: muscle)
        DashboardCard(
            title: muscle.name,
            subtitle: "Last 7 Days",
            subsubtitle: data.total.formatted(.number.precision(.fractionLength(0...1))),
            subsubsubtitle: "sets",
            chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
        ) {
            SetsBarChart(data: data.last7Days, color: .blue)
        }
        .tappableBackground()
        .anyButton(.press) {
            presenter.onMusclePressed(muscle: muscle)
        }
    }
}

extension CoreBuilder {
    
    func muscleGroupsView(router: Router, delegate: MuscleGroupsDelegate) -> some View {
        MuscleGroupsView(
            presenter: MuscleGroupsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showMuscleGroupsView(delegate: MuscleGroupsDelegate) {
        router.showScreen(.sheet) { router in
            builder.muscleGroupsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = MuscleGroupsDelegate()
    
    return RouterView { router in
        builder.muscleGroupsView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
