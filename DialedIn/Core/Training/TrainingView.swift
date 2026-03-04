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

struct TrainingDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct TrainingView<CalendarHeaderView: View>: View {

    @Environment(\.layoutMode) private var layoutMode
    @Environment(\.scenePhase) private var scenePhase

    @State var presenter: TrainingPresenter
    let delegate: TrainingDelegate
    
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
        .navigationTitle("Training")
        .toolbarTitleDisplayMode(.inlineLarge)
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
        .toolbarRole(.browser)
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
                .listRowInsets(.leading, 0)
            } label: {
                HStack(spacing: 12) {
                    HStack {
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
                    }
                    .anyButton(.press) {
                        presenter.onProgramPressed(program: program)
                    }
                    Spacer()
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        presenter.onProgramDeletePressed(program: program)
                    }
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
                Text(item.workoutTemplate.name)
                    .font(.subheadline)
                if !item.workoutTemplate.exercises.isEmpty {
                    MetricView(
                        label: "Exercises",
                        value: "\(item.workoutTemplate.exercises.count)",
                        icon: "dumbbell"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let sessionId = item.completedSessionId {
                presenter.openCompletedSession(sessionId: sessionId)
            } else {
                presenter.startWorkoutTemplateModelWorkout(item.workoutTemplate, in: item.trainingProgramId)
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
                Group {
                    Label("Training Program Library", systemImage: "books.vertical")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .tappableBackground()
                        .anyButton {
                            presenter.onProgramManagementPressed()
                        }
                    
                    Label("Workout Library", systemImage: "dumbbell")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .tappableBackground()
                        .anyButton {
                            presenter.onWorkoutLibraryPressed()
                        }
                    
                    Label("Workout History", systemImage: "list.bullet")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .tappableBackground()
                        .anyButton {
                            presenter.onWorkoutHistoryPressed()
                        }
                }
                .foregroundStyle(.primary)
            } header: {
                Text("More")
            }
        }
    }
            
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        #if DEV || MOCK
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        
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
    func trainingView(delegate: TrainingDelegate, router: AnyRouter) -> some View {
        TrainingView(
            presenter: TrainingPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate,
            calendarHeader: { delegate in
                self.calendarHeaderView(router: router, delegate: delegate)
            }
        )
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = TrainingDelegate()
    RouterView { router in
        builder.trainingView(delegate: delegate, router: router)
    }
    
}
