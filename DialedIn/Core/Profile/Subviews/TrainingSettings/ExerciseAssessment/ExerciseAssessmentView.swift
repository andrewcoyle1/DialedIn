import SwiftUI

struct ExerciseAssessmentDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct ExerciseAssessmentView: View {
    
    @State var presenter: ExerciseAssessmentPresenter
    let delegate: ExerciseAssessmentDelegate
    
    var body: some View {
        Text("Hello, World!")
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
    let delegate = ExerciseAssessmentDelegate()
    
    return RouterView { router in
        builder.exerciseAssessmentView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func exerciseAssessmentView(router: AnyRouter, delegate: ExerciseAssessmentDelegate) -> some View {
        ExerciseAssessmentView(
            presenter: ExerciseAssessmentPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showExerciseAssessmentView(delegate: ExerciseAssessmentDelegate) {
        router.showScreen(.push) { router in
            builder.exerciseAssessmentView(router: router, delegate: delegate)
        }
    }
    
}
