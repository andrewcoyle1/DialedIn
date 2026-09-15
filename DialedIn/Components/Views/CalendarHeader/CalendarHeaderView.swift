import SwiftUI

struct CalendarHeaderDelegate {
    var onDatePressed: (Date) -> Void
    var getForDate: (Date) -> Int
}

struct CalendarHeaderView: View {

    @Environment(\.colorScheme) private var colorScheme

    @State var presenter: CalendarHeaderPresenter

    @Namespace private var namespace

    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                ForEach(presenter.weeks, id: \.self) { week in
                    weekBlock(week)
                }
            }
            // Belongs on the layout inside the scroll view, not on the ScrollView,
            // or viewAligned paging has nothing to snap to.
            .scrollTargetLayout()
        }
        .frame(height: Self.rowHeight)
        .scrollIndicators(.hidden)
        .scrollPosition(id: $presenter.weekScrollPosition, anchor: .leading)
        .scrollTargetBehavior(.viewAligned)
        .padding(.horizontal)
        .glassEffect()
        .padding(.horizontal)
        .matchedTransitionSource(id: "calendar-header", in: namespace)
    }

    private static let rowHeight: CGFloat = 70

    /// A week fills exactly one page of the scroll view. Sized from the scroll container
    /// rather than a GeometryReader wrapped around the padding — the reader measured the
    /// full width before the two horizontal paddings were applied, so each week was ~64pt
    /// wider than the visible area and the last day was cut off mid-snap.
    @ViewBuilder
    private func weekBlock(_ week: [Date]) -> some View {
        HStack(spacing: 0) {
            ForEach(week, id: \.self) { (day: Date) in
                dayCell(day)
            }
        }
        .containerRelativeFrame(.horizontal)
        .id(week.first ?? Date.distantPast)
    }

    @ViewBuilder
    private func dayCell(_ day: Date) -> some View {
        let activityCount = presenter.getForDate(day)
        let isToday = presenter.calendar.isDate(day, inSameDayAs: presenter.today)
        let isSelected = presenter.calendar.isDate(day, inSameDayAs: presenter.selectedDate)

        VStack(spacing: 2) {
            Text(day.formatted(.dateTime.weekday(.narrow)))
                .font(.caption2)
                .foregroundStyle(isSelected ? AnyShapeStyle(.white) : AnyShapeStyle(.secondary))
            Text(day.formatted(.dateTime.day()))
                .font(.subheadline)
                .foregroundStyle(dayNumberStyle(isSelected: isSelected, isToday: isToday))
        }
        .monospaced()
        .fontWeight(isSelected || isToday ? .semibold : .regular)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background {
            cellOutline(activityCount: activityCount, isSelected: isSelected, isToday: isToday)
                .padding(.horizontal, 4)
        }
        .overlay(alignment: .topTrailing) {
            if activityCount > 1 {
                cellBadge(activityCount: activityCount)
            }
        }
        .contentShape(.rect)
        .interactionReader(
            longPressSensitivity: 500,
            tapAction: {
                presenter.onDatePressed(day)
            },
            longPressAction: {
                presenter.showLargeCalendar("calendar-header", in: namespace)
            },
            scaleEffect: false
        )
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    private func dayNumberStyle(isSelected: Bool, isToday: Bool) -> AnyShapeStyle {
        if isSelected {
            return AnyShapeStyle(.white)
        } else if isToday {
            return AnyShapeStyle(Color.accentColor)
        } else {
            return AnyShapeStyle(.primary)
        }
    }

    @ViewBuilder
    private func cellOutline(activityCount: Int, isSelected: Bool, isToday: Bool) -> some View {
        Capsule()
            .fill(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(colorScheme.backgroundPrimary))
            .overlay {
                if isSelected {
                    EmptyView()
                } else if isToday || activityCount > 0 {
                    Capsule()
                        .stroke(.tint, lineWidth: 2)
                } else {
                    Capsule()
                        .stroke(.secondary.opacity(0.5), lineWidth: 2)
                }
            }
    }
    
    @ViewBuilder
    private func cellBadge(activityCount: Int) -> some View {
        Text(activityCount > 9 ? "9+" : "\(activityCount)")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(colorScheme.backgroundSecondary)
            .padding(4)
            .background {
                Circle()
                    .fill(.tint)
            }
            .offset(x: 6, y: -6)
    }
}

extension CoreBuilder {
    
    func calendarHeaderView(router: AnyRouter, delegate: CalendarHeaderDelegate) -> some View {
        CalendarHeaderView(
            presenter: CalendarHeaderPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self),
                delegate: delegate
            )
        )
    }
    
}

extension CoreRouter {
    
    func showCalendarHeaderView(delegate: CalendarHeaderDelegate) {
        router.showScreen(.push) { router in
            builder.calendarHeaderView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = CalendarHeaderDelegate(
        onDatePressed: { date in
            print(date.formatted(date: .abbreviated, time: .omitted))
        },
        getForDate: { date in
            return date.timeIntervalSince1970.exponent
        }
    )
    
    return RouterView { router in
        List {
            Text("Hello")
        }
        .scrollEdgeEffectStyle(.soft, for: .top)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {

                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
        .safeAreaInset(edge: .top) {
            builder.calendarHeaderView(router: router, delegate: delegate)
        }
    }
}
