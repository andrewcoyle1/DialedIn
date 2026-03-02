import SwiftUI

struct DashboardDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct DashboardView<WorkoutSessionRow: View>: View {
    
    @State var presenter: DashboardPresenter
    let delegate: DashboardDelegate
    
    @ViewBuilder var workoutSessionRow: (WorkoutSessionRowDelegate) -> WorkoutSessionRow
    
    private var showDevSettingsButton: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }

    var body: some View {
        List {
            streakSection
            workoutFeedSection
        }
        .navigationTitle("Dashboard")
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
        .toolbar { toolbarContent }
    }
    
    private var streakSection: some View {
        Section {
            HStack {
                Text(presenter.workoutStreakCount == 1 ? "1 day" : "\(presenter.workoutStreakCount) days")
                    .font(.headline)
                if presenter.isStreakActive {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                }
            }
        } header: {
            Text("Workout Streak")
        }
    }
    
    private var workoutFeedSection: some View {
        Section {
            ForEach(presenter.feedSessions) { session in
                if let author = presenter.author(for: session) {
                    let rowDelegate = WorkoutSessionRowDelegate(session: session, author: author)
                    workoutSessionRow(rowDelegate)
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Feed")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if showDevSettingsButton {
                Button {
                    presenter.onDevSettingsPressed()
                } label: {
                    Image(systemName: "info")
                }
            }
        }
        
        ToolbarSpacer(.fixed, placement: .topBarTrailing)
        
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onPushNotificationsPressed()
            } label: {
                Image(systemName: "bell")
            }
            .badge(3)
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

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = DashboardDelegate()
    
    return RouterView { router in
        builder.dashboardView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func dashboardView(router: AnyRouter, delegate: DashboardDelegate) -> some View {
        DashboardView(
            presenter: DashboardPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate,
            workoutSessionRow: { delegate in
                self.workoutSessionRowView(router: router, delegate: delegate)
            }
        )
    }
    
}

extension CoreRouter {
    
    func showDashboardView(delegate: DashboardDelegate) {
        router.showScreen(.push) { router in
            builder.dashboardView(router: router, delegate: delegate)
        }
    }
    
}
