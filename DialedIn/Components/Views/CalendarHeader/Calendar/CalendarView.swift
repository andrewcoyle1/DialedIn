//
//  CalendarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI

struct CalendarDelegate {
    /// The day the header is currently on, so the sheet opens there rather than on today.
    var selectedDate: Date = .now
    var onDateSelected: (Date, Date) -> Void
    /// Same map the week strip uses, so both mark the same days as having activity.
    var activityCountsByDay: () -> [Date: Int] = { [:] }
}

struct CalendarView: View {

    @State var presenter: CalendarPresenter

    /// Scrolling is driven through a `ScrollViewProxy` rather than `scrollPosition(id:)`,
    /// because that binding resolves against the scroll target layout's immediate children and
    /// a pinned `Section` splits each month into two of them — header and grid — leaving the
    /// initial position and the Today button without an anchor.
    @State private var scrollProxy: ScrollViewProxy?

    var body: some View {
        VStack(spacing: 0) {
            daysOfWeekHeader

            monthsScrollView
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }

    private var daysOfWeekHeader: some View {
        HStack(spacing: 0) {
            ForEach(presenter.daysOfWeek.indices, id: \.self) { index in
                Text(presenter.daysOfWeek[index])
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .monospaced()
        .padding(.horizontal)
        .padding(.bottom, 8)
        .background(.bar)
    }

    private var monthsScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 16, pinnedViews: .sectionHeaders) {
                    ForEach(presenter.months) { month in
                        Section {
                            monthGrid(month)
                        } header: {
                            // The id sits on the header rather than the `Section`, so
                            // `scrollTo` has a plain view to find and lands on the month title.
                            monthHeader(month)
                                .id(month.id)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .onAppear {
                scrollProxy = proxy
            }
            .task {
                // A hop after the first layout pass: scrolling straight from `onAppear` asks
                // the lazy stack for a month it has not built yet.
                await Task.yield()
                // No animation — this is the sheet's opening position, not a movement.
                proxy.scrollTo(presenter.initialMonth, anchor: .top)
            }
        }
    }

    /// The background hugs the title rather than filling the row, so the grid keeps its own
    /// background either side of it. The capsule matches the day cells.
    private func monthHeader(_ month: CalendarPresenter.Month) -> some View {
        Text(month.title)
            .font(.headline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.bar, in: .capsule)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 4)
    }

    private func monthGrid(_ month: CalendarPresenter.Month) -> some View {
        LazyVGrid(columns: presenter.columns, spacing: 6) {
            ForEach(Array(month.days.enumerated()), id: \.offset) { _, day in
                if let day {
                    dayCell(day)
                } else {
                    // Keeps the 1st in its own weekday column.
                    Color.clear
                        .frame(height: 1)
                }
            }
        }
        .padding(.horizontal)
    }

    /// The same cell the week strip draws, so the sheet reads as the expanded form of the
    /// header rather than a second calendar.
    private func dayCell(_ day: Date) -> some View {
        CalendarDayCell(
            day: day,
            activityCount: presenter.activityCount(for: day),
            isToday: presenter.isToday(day),
            isSelected: presenter.isSelected(day)
        )
        .onTapGesture {
            presenter.onDateSelected(day: day)
        }
        .accessibilityAddTraits(.isButton)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        ToolbarItem(placement: .title) {
            Text("Calendar")
                .font(.headline)
                .foregroundStyle(.primary)
        }

        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDismissPressed()
            } label: {
                Image(systemName: "xmark")
            }
            .accessibilityLabel("Close")
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                withAnimation {
                    scrollProxy?.scrollTo(presenter.currentMonth, anchor: .top)
                }
            } label: {
                Text("Today")
            }
        }
    }

}

extension CoreBuilder {

    func calendarView(router: AnyRouter, delegate: CalendarDelegate) -> some View {
        CalendarView(
            presenter: CalendarPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            )
        )
    }

}

extension CoreRouter {

    /// Tall enough for six week rows, the weekday header and the toolbar. The previous
    /// 0.45 fraction cut the last row off on shorter devices.
    static let calendarSheetHeight: CGFloat = 420

    func showCalendarView(delegate: CalendarDelegate) {
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.height(Self.calendarSheetHeight)]))) { router in
            builder.calendarView(router: router, delegate: delegate)
        }
    }

    /// `onDidDismiss` runs after the router has finished tearing the sheet down, which is the
    /// only safe point to present another screen in response to the selection — anything
    /// presented before that is swept away by the router's clean-up pass.
    func showCalendarViewZoom(
        delegate: CalendarDelegate,
        onDismiss: (() -> Void)? = nil,
        onDidDismiss: (() -> Void)? = nil,
        transitionId: String?,
        namespace: Namespace.ID
    ) {
        router.showScreenWithZoomTransition(
            .sheetConfig(config: ResizableSheetConfig(detents: [.height(Self.calendarSheetHeight), .large], dragIndicator: .visible)),
            onDismiss: onDismiss,
            onDidDismiss: onDidDismiss,
            transitionID: transitionId,
            namespace: namespace) { router in
                builder.calendarView(router: router, delegate: delegate)
            }
    }
}

// MARK: - Previews

/// `CalendarInteractor` is empty and `CalendarRouter` only needs an `AnyRouter`, so the sheet
/// previews without `DevPreview`, whose container opens eighteen SwiftData stores in `init`.
private struct PreviewCalendarInteractor: CalendarInteractor { }

@MainActor
private struct PreviewCalendarRouter: CalendarRouter {
    let router: AnyRouter
}

@MainActor
private func previewCalendarDelegate() -> CalendarDelegate {
    CalendarDelegate(
        selectedDate: .now,
        onDateSelected: { date, _ in
            print("Date selected: \(date.formatted(date: .abbreviated, time: .omitted))")
        },
        activityCountsByDay: {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: .now)
            return (-40...5).reduce(into: [Date: Int]()) { counts, offset in
                guard offset % 3 != 0, let day = calendar.date(byAdding: .day, value: offset, to: today) else { return }
                counts[day] = offset % 7 == 0 ? 3 : 1
            }
        }
    )
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            RouterView { router in
                CalendarView(
                    presenter: CalendarPresenter(
                        interactor: PreviewCalendarInteractor(),
                        router: PreviewCalendarRouter(router: router),
                        delegate: previewCalendarDelegate()
                    )
                )
            }
            .presentationDetents([.height(CoreRouter.calendarSheetHeight), .large])
        }
}
