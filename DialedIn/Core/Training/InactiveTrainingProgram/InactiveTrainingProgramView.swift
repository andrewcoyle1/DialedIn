import SwiftUI

struct InactiveTrainingProgramDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct InactiveTrainingProgramView: View {
    
    @State var presenter: InactiveTrainingProgramPresenter
    let delegate: InactiveTrainingProgramDelegate
    
    var body: some View {
        List {
            ForEach(presenter.trainingPrograms) { program in
                DisclosureGroup {
                    ForEach(program.workoutTemplates) { workout in
                        HStack {
                            WorkoutTemplateRow(workoutTemplate: workout)
                            Image(systemName: "chevron.right")
                        }
                    }
                    .listRowInsets(.leading, 0)
                } label: {
                    TrainingProgramHeader(program: program)
                }
            }
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = InactiveTrainingProgramDelegate()
    
    return RouterView { router in
        builder.inactiveTrainingProgramView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func inactiveTrainingProgramView(router: AnyRouter, delegate: InactiveTrainingProgramDelegate) -> some View {
        InactiveTrainingProgramView(
            presenter: InactiveTrainingProgramPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showInactiveTrainingProgramView(delegate: InactiveTrainingProgramDelegate) {
        router.showScreen(.push) { router in
            builder.inactiveTrainingProgramView(router: router, delegate: delegate)
        }
    }
    
}
