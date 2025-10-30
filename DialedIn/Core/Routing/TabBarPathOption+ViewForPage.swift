//
//  TabBarPathOption+ViewForPage.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import SwiftUI

extension TabBarOption {
    /// A view builder that the split view uses to show a view for the selected navigation option.
    @MainActor @ViewBuilder func viewForPage(container: DependencyContainer) -> some View {
        switch self {
        case .dashboard: DashboardView(viewModel: DashboardViewModel(interactor: CoreInteractor(container: container)))
        case .nutrition: NutritionView(viewModel: NutritionViewModel(interactor: CoreInteractor(container: container)))
        case .training: TrainingView(viewModel: TrainingViewModel(interactor: CoreInteractor(container: container)))
        case .profile: ProfileView(viewModel: ProfileViewModel(interactor: CoreInteractor(container: container)))
        case .search: SearchView()
        }
    }
}
