//
//  TabBarPath+ViewForPage.swift
//  DialedIn
//
//  Created by Andrew Coyle on 29/10/2025.
//

import SwiftUI

extension TabBarOption {
    /// A view builder that the split view uses to show a view for the selected navigation option.
    @MainActor @ViewBuilder func viewForPage(builder: CoreBuilder, path: Binding<[TabBarPathOption]>) -> some View {
        switch self {
        case .dashboard: builder.dashboardView(delegate: DashboardViewDelegate(path: path))
        case .nutrition: builder.nutritionView(delegate: NutritionViewDelegate(path: path))
        case .training: builder.trainingView(delegate: TrainingViewDelegate(path: path))
        case .profile: builder.profileView(delegate: ProfileViewDelegate(path: path))
        case .search: SearchView()
        }
    }
}
