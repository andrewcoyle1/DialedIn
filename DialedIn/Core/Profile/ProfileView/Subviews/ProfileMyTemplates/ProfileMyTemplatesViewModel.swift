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

@Observable
@MainActor
class ProfileMyTemplatesViewModel {
    private let interactor: ProfileMyTemplatesInteractor
    
    var currentUser: UserModel? {
        interactor.currentUser
    }
    
    init(interactor: ProfileMyTemplatesInteractor) {
        self.interactor = interactor
    }

    func navToExerciseTemplateList(path: Binding<[TabBarPathOption]>) {
        guard let templateIds = interactor.currentUser?.createdExerciseTemplateIds else { return }
        interactor.trackEvent(event: Event.navigate(destination: .exerciseTemplateList(templateIds: templateIds)))
        path.wrappedValue.append(.exerciseTemplateList(templateIds: templateIds))
    }

    func navToWorkoutTemplateList(path: Binding<[TabBarPathOption]>) {
        guard let templateIds = interactor.currentUser?.createdWorkoutTemplateIds else { return }
        interactor.trackEvent(event: Event.navigate(destination: .workoutTemplateList(templateIds: templateIds)))
        path.wrappedValue.append(.workoutTemplateList(templateIds: templateIds))
    }

    func navToIngredientTemplateList(path: Binding<[TabBarPathOption]>) {
        guard let templateIds = interactor.currentUser?.createdIngredientTemplateIds else { return }
        interactor.trackEvent(event: Event.navigate(destination: .ingredientTemplateList(templateIds: templateIds)))
        path.wrappedValue.append(.ingredientTemplateList(templateIds: templateIds))
    }

    func navToRecipeTemplateList(path: Binding<[TabBarPathOption]>) {
        guard let templateIds = interactor.currentUser?.createdRecipeTemplateIds else { return }
        interactor.trackEvent(event: Event.navigate(destination: .recipeTemplateList(templateIds: templateIds)))
        path.wrappedValue.append(.recipeTemplateList(templateIds: templateIds))
    }

    enum Event: LoggableEvent {
        case navigate(destination: TabBarPathOption)

        var eventName: String {
            switch self {
            case .navigate:     return "ProfileMyTemplates_Navigate"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .navigate(destination: let destination):
                return destination.eventParameters
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
