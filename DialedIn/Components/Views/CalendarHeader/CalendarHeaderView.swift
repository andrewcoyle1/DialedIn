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
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(Array(presenter.weeks.enumerated()), id: \.offset) { _, week in
                        weekBlock(geometry, week)
                    }
                }
                .frame(height: 70)
            }
            .scrollIndicators(.hidden)
            .scrollPosition(id: $presenter.weekScrollPosition, anchor: .leading)
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
        }
        .frame(height: 70)
        .padding(.horizontal)
        .glassEffect()
        .padding(.horizontal)
        .matchedTransitionSource(id: "calendar-header", in: namespace)
    }
    
    @ViewBuilder
    private func weekBlock(_ geometry: GeometryProxy, _ week: [Date]) -> some View {
        HStack(spacing: 0) {
            ForEach(week, id: \.self) { (day: Date) in
                dayCell(geometry, day)
            }
        }
        .frame(width: geometry.size.width)
        .id(week.first ?? Date.distantPast)
    }

    @ViewBuilder
    private func dayCell(_ geometry: GeometryProxy, _ day: Date) -> some View {
        let activityCount = presenter.getForDate(day)

        VStack {
            Text(day.formatted(.dateTime.weekday(.narrow)))
                .foregroundStyle(.secondary)
            Text(day.formatted(.dateTime.day()))
        }
        .monospaced()
        .foregroundStyle(presenter.calendar.isDate(day, inSameDayAs: Date.now) ? .blue : .primary)
        .fontWeight(presenter.calendar.isDate(day, inSameDayAs: Date.now) ? .semibold : .regular)
        .padding(.vertical, 8)
        .frame(width: 40)
        .background {
            cellOutline(activityCount: activityCount)
        }
        .overlay(alignment: .topTrailing) {
            if activityCount > 1 {
                cellBadge(activityCount: activityCount)
            }
        }
        .frame(width: geometry.size.width / 7)
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
    }

    @ViewBuilder
    private func cellOutline(activityCount: Int) -> some View {
        Capsule()
            .fill(colorScheme.backgroundPrimary)
            .overlay {
                if activityCount > 0 {
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
            .foregroundStyle(.white)
            .padding(4)
            .background {
                Circle()
                    .fill(.tint)
            }
            .offset(x: 6, y: -6)
    }
}

extension CoreBuilder {
    
    func calendarHeaderView(router: Router, delegate: CalendarHeaderDelegate) -> some View {
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
    .previewEnvironment()
}
