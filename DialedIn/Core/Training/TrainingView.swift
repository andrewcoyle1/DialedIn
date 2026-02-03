//
//  TrainingView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 23/09/2025.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif
import SwiftfulRouting

struct TrainingView<CalendarHeaderView: View>: View {

    @Environment(\.layoutMode) private var layoutMode

    @State var presenter: TrainingPresenter

    @ViewBuilder var calendarHeader: (CalendarHeaderDelegate) -> CalendarHeaderView

    var body: some View {
        List {
            
            if let program = presenter.activeTrainingProgram {
                trainingProgramHeaderSection(program: program)
            } else {
                noScheduleView
            }
            
            moreSection
        }
//        .refreshable {
//            await presenter.refreshData()
//        }
        .navigationTitle("Training")
        .toolbarTitleDisplayMode(.inlineLarge)
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
        .toolbarRole(.browser)
        .onAppear {
            presenter.getWeeklyProgress()
            Task {
                await presenter.refreshFavouriteGymProfileImage()
            }
        }
        .onFirstTask {
            await presenter.loadData()
        }
        .safeAreaInset(edge: .top) {
            calendarHeader(
                CalendarHeaderDelegate(
                    onDatePressed: { date in
                        presenter.onDatePressed(date: date)
                    },
                    getForDate: { date in
                        presenter.getLoggedWorkoutCountForDate(date, calendar: presenter.calendar)
                    }
                )
            )
        }
    }
    
    private func trainingProgramHeaderSection(program: TrainingProgram) -> some View {
        Section {
            DisclosureGroup(isExpanded: $presenter.activeProgramisExpanded) {
                let items = presenter.currentMicrocycleItems()
                ForEach(items) { item in
                    microcycleItemRow(item: item)
                }
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: program.colour).opacity(0.2))
                        Image(systemName: program.icon)
                        
                            .foregroundStyle(Color(hex: program.colour))
                    }
                    .frame(width: 44, height: 44)
                    
                    Text(program.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    
                }
            }
        } header: {
            HStack {
                Text("Active Program")
                Spacer()
                Text(presenter.microcycleHeaderText)
                    .font(.caption)
                    .underline()

            }
        }
        .listSectionMargins(.top, 0)
    }
    
    @ViewBuilder
    private func microcycleItemRow(item: MicrocycleItem) -> some View {
        HStack(spacing: 16) {
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(item.isCompleted ? .green : .secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.dayPlan.name)
                    .font(.subheadline)
                MetricView(
                    label: "Exercises",
                    value: "\(item.dayPlan.exercises.count)",
                    icon: "dumbbell"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let sessionId = item.completedSessionId {
                presenter.openCompletedSession(sessionId: sessionId)
            } else {
                presenter.startDayPlanWorkout(item.dayPlan)
            }
        }
    }
            
    private var noScheduleView: some View {
        Group {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    
                    Text("No Active Schedule")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Start a training plan to schedule workouts and track your progress")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        presenter.onChooseProgramPressed()
                    } label: {
                        Label("Choose Program", systemImage: "plus.circle.fill")
                            .foregroundStyle(Color.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            }
        }
    }
    
    private var moreSection: some View {
        Group {
            Section {

                CustomListCellView(
                    sfSymbolName: "books.vertical",
                    title: "Training Program Library"
                )
                .anyButton {
                    presenter.onProgramManagementPressed()
                }
                .removeListRowFormatting()

                CustomListCellView(
                    sfSymbolName: "dumbbell",
                    title: "Workout Library"
                )
                .anyButton {
                    presenter.onWorkoutLibraryPressed()
                }
                .removeListRowFormatting()
            
                CustomListCellView(
                    sfSymbolName: "list.bullet",
                    title: "Workout History"
                )
                .anyButton {
                    presenter.onWorkoutHistoryPressed()
                }
                .removeListRowFormatting()
            } header: {
                Text("More")
            }
        }
    }
            
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onAddPressed()
            } label: {
                Image(systemName: "plus")
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
    func trainingView(router: AnyRouter) -> some View {
        TrainingView(
            presenter: TrainingPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            calendarHeader: { delegate in
                self.calendarHeaderView(router: router, delegate: delegate)
            }
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        builder.trainingView(router: router)
    }
    .previewEnvironment()
}

#Preview("No Training Plan") {
    let container = DevPreview.shared.container()
    container.register(TrainingPlanManager.self, service: TrainingPlanManager(services: MockTrainingPlanServices(delay: 0, showError: false, plans: [])))
    let builder = CoreBuilder(container: container)
    return RouterView { router in
        builder.trainingView(router: router)
    }
    .previewEnvironment()
}
