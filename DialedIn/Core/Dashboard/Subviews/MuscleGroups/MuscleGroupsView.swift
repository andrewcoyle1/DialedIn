import SwiftUI

struct MuscleGroupsDelegate {
    
}

struct MuscleGroupsView: View {
    
    @State var presenter: MuscleGroupsPresenter
    let delegate: MuscleGroupsDelegate
    
    var body: some View {
        List {
            Section {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(presenter.upperMuscles, id: \.self) { muscle in
                        DashboardCard(title: muscle.name, subtitle: "Last 7 Days", subsubtitle: "6", subsubsubtitle: "sets")
                            .tappableBackground()
                            .anyButton(.press) {

                            }
                    }
                }
                .padding(.horizontal, 8)
                .removeListRowFormatting()

            } header: {
                Text("Upper")
            }

            Section {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(presenter.lowerMuscles, id: \.self) { muscle in
                        DashboardCard(title: muscle.name, subtitle: "Last 7 Days", subsubtitle: "6", subsubsubtitle: "sets")
                            .tappableBackground()
                            .anyButton(.press) {

                            }
                    }
                }
                .padding(.horizontal, 8)
                .removeListRowFormatting()

            } header: {
                Text("Lower")
            }
        }
        .navigationTitle("Muscle Groups")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "MuscleGroupsView")
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
