import SwiftUI

struct CalendarHeaderDelegate {
    var onDatePressed: (Date) -> Void

    /// Activity counts keyed by `startOfDay`, supplied in one call for the whole header.
    var activityCountsByDay: () -> [Date: Int]
}

struct CalendarHeaderView: View {

    @Environment(\.colorScheme) private var colorScheme

    @State var presenter: CalendarHeaderPresenter

    /// Driven by a toolbar button in the parent screen. The header owns the transition
    /// namespace, so it is what actually presents; the parent only asks.
    @Binding var isCalendarExpanded: Bool

    /// View state, not presenter state: bound to the presenter it wrote through `@Observable`
    /// on every scroll update, invalidating the whole header — all seven cells — mid-swipe.
    @State private var weekScrollPosition: Date?

    @Namespace private var namespace

    var body: some View {
        // Built once per body pass and looked up per cell.
        let activityCounts = presenter.activityCountsByDay()

        return ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(presenter.weeks) { week in
                    weekBlock(week, activityCounts: activityCounts)
                }
            }
            // Belongs on the layout inside the scroll view, not on the ScrollView,
            // or viewAligned paging has nothing to snap to.
            .scrollTargetLayout()
        }
        .frame(height: Self.rowHeight)
        .scrollIndicators(.hidden)
        .scrollPosition(id: $weekScrollPosition, anchor: .leading)
        .scrollTargetBehavior(.viewAligned)
//        .padding(.horizontal)
//        .glassEffect()
//        .padding(.bottom, 8)
//        .padding(.horizontal)
        .matchedTransitionSource(id: "calendar-header", in: namespace)
        .background(.bar)
        .onAppear {
            if weekScrollPosition == nil {
                weekScrollPosition = presenter.currentWeekStart
            }
        }
        .task {
            for await _ in NotificationCenter.default.notifications(named: .NSCalendarDayChanged) {
                presenter.refreshToday()
            }
        }
        .onChange(of: isCalendarExpanded) { _, isExpanded in
            guard isExpanded else { return }
            presenter.showLargeCalendar("calendar-header", in: namespace) {
                isCalendarExpanded = false
            }
        }
    }

    private static let rowHeight: CGFloat = 70

    /// A week fills exactly one page of the scroll view, so the side inset has to sit *inside*
    /// `containerRelativeFrame` — padding applied outside it adds to the page width, pushing
    /// each week 32pt wider than the screen and spilling the last cell off the right edge.
    @ViewBuilder
    private func weekBlock(_ week: CalendarHeaderPresenter.Week, activityCounts: [Date: Int]) -> some View {
        HStack {
            ForEach(week.days, id: \.self) { (day: Date) in
                dayCell(day, activityCount: activityCounts[day] ?? 0)
            }
        }
        .padding(.horizontal)
        .containerRelativeFrame(.horizontal)
    }

    @ViewBuilder
    private func dayCell(_ day: Date, activityCount: Int) -> some View {
        CalendarDayCell(
            day: day,
            activityCount: activityCount,
            isToday: presenter.calendar.isDate(day, inSameDayAs: presenter.today),
            isSelected: presenter.calendar.isDate(day, inSameDayAs: presenter.selectedDate),
            showsWeekday: true
        )
        // A plain tap rather than a zero-distance DragGesture: the scroll view cancels this
        // cleanly, where the drag gesture left `isPressing` stuck true when the scroll took
        // over. The expanded calendar is a toolbar button in the parent, not a long press.
        .onTapGesture {
            presenter.onDatePressed(day)
        }
        .accessibilityAddTraits(.isButton)
    }

}

extension CoreBuilder {
    
    func calendarHeaderView(
        router: AnyRouter,
        delegate: CalendarHeaderDelegate,
        isCalendarExpanded: Binding<Bool>
    ) -> some View {
        CalendarHeaderView(
            presenter: CalendarHeaderPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            ),
            isCalendarExpanded: isCalendarExpanded
        )
    }
    
}

// MARK: - Previews

/// Preview stand-ins for the two protocols this screen depends on, both of which are a single
/// method. `DevPreview.shared.container()` builds every manager in the app, and eighteen of its
/// sync engines open a SwiftData store and read it synchronously inside `init` — work the
/// header does not need, paid before anything renders.
@MainActor
private struct PreviewCalendarHeaderInteractor: CalendarHeaderInteractor {
    func trackEvent(event: LoggableEvent) { }
}

@MainActor
private struct PreviewCalendarHeaderRouter: CalendarHeaderRouter {
    func showCalendarViewZoom(
        delegate: CalendarDelegate,
        onDismiss: (() -> Void)?,
        transitionId: String?,
        namespace: Namespace.ID
    ) { }
}

@MainActor
private func previewDelegate() -> CalendarHeaderDelegate {
    CalendarHeaderDelegate(
        onDatePressed: { date in
            print(date.formatted(date: .abbreviated, time: .omitted))
        },
        activityCountsByDay: {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: .now)
            return (-3...3).reduce(into: [Date: Int]()) { counts, offset in
                guard let day = calendar.date(byAdding: .day, value: offset, to: today) else { return }
                counts[day] = abs(offset)
            }
        }
    )
}

#Preview("Calendar Header") {
    @Previewable @State var isCalendarExpanded = false

    CalendarHeaderView(
        presenter: CalendarHeaderPresenter(
            interactor: PreviewCalendarHeaderInteractor(),
            router: PreviewCalendarHeaderRouter(),
            delegate: previewDelegate()
        ),
        isCalendarExpanded: $isCalendarExpanded
    )
}

#Preview("In a screen") {
    @Previewable @State var isCalendarExpanded = false

    NavigationStack {
        List {
            Text("Hello")
        }
        .navigationTitle("Calendar Header Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // Stands in for the parent screen's button. The preview router does not present
            // anything, so this only shows the wiring.
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isCalendarExpanded = true
                } label: {
                    Image(systemName: "calendar")
                }
            }
        }
        .safeAreaInset(edge: .top) {
            CalendarHeaderView(
                presenter: CalendarHeaderPresenter(
                    interactor: PreviewCalendarHeaderInteractor(),
                    router: PreviewCalendarHeaderRouter(),
                    delegate: previewDelegate()
                ),
                isCalendarExpanded: $isCalendarExpanded
            )
        }
    }
}

///// The full dependency graph, for checking the real routing into the expanded calendar.
///// Slow to start — that is `DevPreview`, not this view.
//#Preview("Full DI") {
//    let container = DevPreview.shared.container()
//    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
//
//    return RouterView { router in
//        List {
//            Text("Hello")
//        }
//        .safeAreaInset(edge: .top) {
//            builder.calendarHeaderView(
//                router: router,
//                delegate: previewDelegate(),
//                isCalendarExpanded: .constant(false)
//            )
//                .background(.bar)
//        }
//    }
//}
