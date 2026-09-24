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

struct TrainingView<CalendarHeaderView: View, ActiveProgramView: View>: View {

    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: TrainingPresenter
    let delegate: TrainingDelegate

    let profileTransitionId: String = "profile_button_transition"
    
    @ViewBuilder var calendarHeader: (CalendarHeaderDelegate, Binding<Bool>) -> CalendarHeaderView
    @ViewBuilder var activeProgramContent: (TrainingProgram) -> ActiveProgramView

    @Namespace private var namespace

    @State private var isCalendarExpanded = false

    var body: some View {
        List {
            if let program = presenter.activeTrainingProgram {
                activeProgramContent(program)
            } else {
                noScheduleView
            }

            moreSection
        }
        .navigationTitle("Training")
        .navigationBarTitleDisplayMode(.inline)
        .scrollIndicators(.hidden)
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .top) {
            calendarHeader(
                CalendarHeaderDelegate(
                    onDatePressed: { date in
                        presenter.onDatePressed(date: date)
                    },
                    // Tapping a day opens that day's session; the screen has no "selected day"
                    // state for a highlight to reflect.
                    showsSelection: false,
                    markersByDay: {
                        presenter.loggedWorkoutMarkersByDay()
                    }
                ),
                $isCalendarExpanded
            )
            .background(.bar)
        }
    }

    private var noScheduleView: some View {
        Section {
            VStack(spacing: 16) {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                
                Text("No Active Training Program")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Add a program to start compounding.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    presenter.onChooseProgramPressed()
                } label: {
                    Label("Choose Program", systemImage: "plus.circle.fill")
                        .foregroundStyle(colorScheme.backgroundPrimary)
                }
                .buttonStyle(.glassProminent)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
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
                            presenter.onTrainingProgramLibraryView()
                        }

                    Label("Workout Library", systemImage: "dumbbell")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .tappableBackground()
                        .anyButton {
                            presenter.onWorkoutLibraryPressed()
                        }

                    Label("Start Empty Workout", systemImage: "plus")
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .tappableBackground()
                        .anyButton {
                            presenter.onStartEmptyWorkoutPressed()
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
            .accessibilityLabel("Developer settings")
        }
        #endif

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                isCalendarExpanded = true
            } label: {
                Image(systemName: "calendar")
            }
            .accessibilityLabel("Show calendar")
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onAddPressed()
            } label: {
                Image(systemName: "plus")
            }
            .accessibilityLabel("Add training")
        }
        
        ToolbarSpacer(.fixed, placement: .topBarTrailing)
        
        ToolbarItem(placement: .topBarTrailing) {
            ProfileButton(
                action: {
                    presenter.onProfilePressed(transitionId: profileTransitionId, namespace: namespace)
                },
                imageUrl: presenter.userImageUrl
            )
            .matchedTransitionSource(id: profileTransitionId, in: namespace)
        }
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
            calendarHeader: { calendarDelegate, isCalendarExpanded in
                self.calendarHeaderView(
                    router: router,
                    delegate: calendarDelegate,
                    isCalendarExpanded: isCalendarExpanded
                )
            },
            activeProgramContent: { program in
                self.activeTrainingProgramView(
                    router: router,
                    delegate: ActiveTrainingProgramDelegate(program: program)
                )
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
