//
//  DashboardView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 25/09/2025.
//

import SwiftUI
import SwiftfulRouting

struct DashboardView: View {

    @Environment(\.layoutMode) private var layoutMode

    @State var presenter: DashboardPresenter

    @ViewBuilder var nutritionTargetChartView: () -> AnyView

    @Namespace private var namespace

    var body: some View {
        List {
            carouselSection
            nutritionTargetSection
            contributionChartSection
        }
        .navigationTitle("Dashboard")
        .navigationSubtitle(presenter.selectedDate.formattedDate)
        .toolbarTitleDisplayMode(.inlineLarge)
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
        .toolbarRole(.browser)
        .onOpenURL { url in
            presenter.handleDeepLink(url: url)
        }
    }
    
    private var inspectorContent: some View {
        Group {
            Text("Select an item")
                .foregroundStyle(.secondary)
                .padding()
        }
        .inspectorColumnWidth(min: 300, ideal: 400, max: 600)
    }
    
    private var carouselSection: some View {
        Section {
            
        } header: {
            
        }
    }
    
    private var nutritionTargetSection: some View {
        Section {
            nutritionTargetChartView()
        } header: {
            Text("Nutrition & Targets")
        }
    }
    
    private var contributionChartSection: some View {
        Section {
            ContributionChartView(
                data: presenter.contributionChartData,
                rows: 7,
                columns: 16,
                targetValue: 1.0,
                blockColor: .accent,
                endDate: presenter.chartEndDate
            )
            .frame(height: 220)
        } header: {
            Text("Workout Consistency")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onAddWeightPressed()
            } label: {
                Image(systemName: "scalemass")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            let avatarSize: CGFloat = 44

            Button {
                presenter.onProfilePressed()
            } label: {
                ZStack {
                    Image(systemName: "person.circle")
                        .font(.system(size: 24))
                    if let urlString = presenter.userImageUrl {
                        ImageLoaderView(urlString: urlString, clipShape: AnyShape(Circle()))
                            .frame(width: avatarSize, height: avatarSize)
                            .contentShape(Circle())
                    }
                }
            }
        }
        .sharedBackgroundVisibility(.hidden)
    }
}

extension CoreBuilder {
    
    func dashboardView(router: AnyRouter) -> some View {
        DashboardView(
            presenter: DashboardPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            nutritionTargetChartView: {
                self.nutritionTargetChartView()
                    .any()
            }
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.dashboardView(router: router)
    }
    .previewEnvironment()
}

#Preview("w/ Notifications Test") {
    let container = DevPreview.shared.container()
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestService(notificationsTest: true), logger: LogManager()))
    let builder = CoreBuilder(container: container)
    return RouterView { router in
        builder.dashboardView(router: router)
    }
    .previewEnvironment()
}
