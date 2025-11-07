//
//  TabBarPath+ViewForPage.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import SwiftUI

extension TabBarOption {
    /// A view builder that the split view uses to show a view for the selected navigation option.
    @MainActor @ViewBuilder func viewForPage(container: DependencyContainer, path: Binding<[TabBarPathOption]>) -> some View {
        switch self {
        case .dashboard: DashboardView(viewModel: DashboardViewModel(interactor: CoreInteractor(container: container)), path: path)
        case .nutrition: NutritionView(viewModel: NutritionViewModel(interactor: CoreInteractor(container: container)), path: path)
        case .training: TrainingView(viewModel: TrainingViewModel(interactor: CoreInteractor(container: container)), path: path)
        case .profile: ProfileView(viewModel: ProfileViewModel(interactor: CoreInteractor(container: container)), path: path)
        case .search: SearchView()
        }
    }
}
