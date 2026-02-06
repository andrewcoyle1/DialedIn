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
                    ForEach(ExerciseModel.mocks) { exercise in
                        DashboardCard(title: exercise.name, subtitle: "Last 7 Workouts", subsubtitle: "45", subsubsubtitle: "kg")
                            .tappableBackground()
                            .anyButton(.press) {

                            }
                    }
                }
                .padding(.horizontal, 8)
                .removeListRowFormatting()
            } header: {
                Text("Last Week")
            }

            Section {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(ExerciseModel.mocks) { exercise in
                        DashboardCard(title: exercise.name, subtitle: "Last 7 Workouts", subsubtitle: "45", subsubsubtitle: "kg")
                            .tappableBackground()
                            .anyButton(.press) {

                            }
                    }
                }
                .padding(.horizontal, 8)
                .removeListRowFormatting()
            } header: {
                Text("Last Month")
            }

            Section(isExpanded: $presenter.isNeverExpanded) {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(ExerciseModel.mocks) { exercise in
                        DashboardCard(title: exercise.name, subtitle: "Last 7 Workouts", subsubtitle: "45", subsubsubtitle: "kg")
                            .tappableBackground()
                            .anyButton(.press) {

                            }
                    }
                }
                .padding(.horizontal, 8)
                .removeListRowFormatting()
            } header: {
                HStack {
                    Text("Last Week")
                    Spacer()
                    Text(presenter.isNeverExpanded ? "Collapse" : "Expand")
                        .font(.caption)
                        .underline()
                        .anyButton {
                            presenter.isNeverExpanded.toggle()
                        }
                }
            }

        }
        .navigationTitle("Exercises")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "ExerciseAnalyticsView")
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
