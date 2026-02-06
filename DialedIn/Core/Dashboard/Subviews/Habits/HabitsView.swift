import SwiftUI

struct HabitsDelegate {
    
}

struct HabitsView: View {
    
    @State var presenter: HabitsPresenter
    let delegate: HabitsDelegate
    
    var body: some View {
        List {
            Section {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    DashboardCard(title: "Weigh In", subtitle: "Last 30 Days", subsubtitle: "3/7", subsubsubtitle: "this week")
                        .tappableBackground()
                        .anyButton(.press) {
                            
                        }
                    DashboardCard(title: "Workouts", subtitle: "Last 30 Days", subsubtitle: "2", subsubsubtitle: "this week")
                        .tappableBackground()
                        .anyButton(.press) {
                            
                        }
                    DashboardCard(title: "Food Logging", subtitle: "Last 30 Days", subsubtitle: "3/7", subsubsubtitle: "this week")
                        .tappableBackground()
                        .anyButton(.press) {
                            
                        }
                }
                .padding(.horizontal, 8)
                .removeListRowFormatting()
            }
        }
        .navigationTitle("Habits")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "HabitsView")
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
    
    func habitsView(router: Router, delegate: HabitsDelegate) -> some View {
        HabitsView(
            presenter: HabitsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showHabitsView(delegate: HabitsDelegate) {
        router.showScreen(.sheet) { router in
            builder.habitsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = HabitsDelegate()
    
    return RouterView { router in
        builder.habitsView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
