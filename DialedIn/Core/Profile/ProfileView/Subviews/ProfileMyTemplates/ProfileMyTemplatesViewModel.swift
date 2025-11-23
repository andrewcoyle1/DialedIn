//
//  ProfileMyTemplatesViewModel.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

protocol ProfileMyTemplatesInteractor {
    var currentUser: UserModel? { get }
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ProfileMyTemplatesInteractor { }

@MainActor
protocol ProfileMyTemplatesRouter {
    func showDevSettingsView()
    func showExerciseTemplateListView(delegate: ExerciseTemplateListViewDelegate)
    func showWorkoutTemplateListView(delegate: WorkoutTemplateListViewDelegate)
    func showIngredientTemplateListView(delegate: IngredientTemplateListViewDelegate)
    func showRecipeTemplateListView(delegate: RecipeTemplateListViewDelegate)
}

extension CoreRouter: ProfileMyTemplatesRouter { }

@Observable
@MainActor
class ProfileMyTemplatesViewModel {
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
        router.showExerciseTemplateListView(delegate: ExerciseTemplateListViewDelegate(templateIds: templateIds))
    }

    func navToWorkoutTemplateList() {
        guard let templateIds = interactor.currentUser?.createdWorkoutTemplateIds else { return }
        interactor.trackEvent(event: Event.navigate)
        router.showWorkoutTemplateListView(delegate: WorkoutTemplateListViewDelegate(templateIds: templateIds))
    }

    func navToIngredientTemplateList() {
        guard let templateIds = interactor.currentUser?.createdIngredientTemplateIds else { return }
        interactor.trackEvent(event: Event.navigate)
        router.showIngredientTemplateListView(delegate: IngredientTemplateListViewDelegate(templateIds: templateIds))
    }

    func navToRecipeTemplateList() {
        guard let templateIds = interactor.currentUser?.createdRecipeTemplateIds else { return }
        interactor.trackEvent(event: Event.navigate)
        router.showRecipeTemplateListView(delegate: RecipeTemplateListViewDelegate(templateIds: templateIds))
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
