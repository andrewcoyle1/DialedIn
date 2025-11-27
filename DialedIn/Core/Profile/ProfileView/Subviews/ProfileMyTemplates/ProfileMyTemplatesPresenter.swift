//
//  ProfileMyTemplatesPresenter.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

@Observable
@MainActor
class ProfileMyTemplatesPresenter {
    private let interactor: ProfileMyTemplatesInteractor
    private let router: ProfileMyTemplatesRouter

    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(
        interactor: ProfileMyTemplatesInteractor,
        router: ProfileMyTemplatesRouter
    ) {
        self.interactor = interactor
        self.router = router
    }

    func navToExerciseTemplateList() {
        guard let templateIds = interactor.currentUser?.createdExerciseTemplateIds else { return }
        interactor.trackEvent(event: Event.navigate)
        router.showExerciseTemplateListView(delegate: ExerciseTemplateListDelegate(templateIds: templateIds))
    }

    func navToWorkoutTemplateList() {
        guard let templateIds = interactor.currentUser?.createdWorkoutTemplateIds else { return }
        interactor.trackEvent(event: Event.navigate)
        router.showWorkoutTemplateListView(delegate: WorkoutTemplateListDelegate(templateIds: templateIds))
    }

    func navToIngredientTemplateList() {
        guard let templateIds = interactor.currentUser?.createdIngredientTemplateIds else { return }
        interactor.trackEvent(event: Event.navigate)
        router.showIngredientTemplateListView(delegate: IngredientTemplateListDelegate(templateIds: templateIds))
    }

    func navToRecipeTemplateList() {
        guard let templateIds = interactor.currentUser?.createdRecipeTemplateIds else { return }
        interactor.trackEvent(event: Event.navigate)
        router.showRecipeTemplateListView(delegate: RecipeTemplateListDelegate(templateIds: templateIds))
    }

    func onDevSettingsPressed() {
        router.showDevSettingsView()
    }

    enum Event: LoggableEvent {
        case navigate

        var eventName: String {
            switch self {
            case .navigate:     return "ProfileMyTemplates_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .navigate:
                return .info
            }
        }
    }
}
