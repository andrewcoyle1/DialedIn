//
//  CalendarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI

struct CalendarDelegate {
    var onDateSelected: (Date, Date) -> Void
}

struct CalendarView: View {

    @State var presenter: CalendarPresenter

    var body: some View {
        VStack(spacing: 16) {

            // Days of the week row
            daysOfWeekHeader

            // Grid of days
            dayGrid

            Spacer(minLength: 0)
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal)
        .padding(.top, 8)
        .toolbar {
            toolbarContent
        }
    }

    private var daysOfWeekHeader: some View {
        HStack(spacing: 0) {
            ForEach(presenter.daysOfWeek.indices, id: \.self) { index in
                Text(presenter.daysOfWeek[index])
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var dayGrid: some View {
        LazyVGrid(columns: presenter.columns, spacing: 6) {
            ForEach(presenter.days, id: \.self) { day in
                Button {
                    presenter.onDateSelected(day: day)
                } label: {
                    dayCell(day)
                }
                .disabled(!presenter.isSelectable(day))
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: presenter.currentMonth)
    }

    /// The day number sits in a fixed-size circle centred in its column. Previously the
    /// circle was the cell background at `maxWidth: .infinity`, so it stretched into a
    /// wide ellipse behind the selected day.
    @ViewBuilder
    private func dayCell(_ day: Date) -> some View {
        let isSelected = presenter.isSelected(day)
        let isToday = presenter.isToday(day)

        Text(day.formatted(.dateTime.day()))
            .font(.subheadline.weight(.medium))
            .monospacedDigit()
            .foregroundStyle(presenter.foregroundStyle(for: day))
            .frame(width: 36, height: 36)
            .background {
                if isSelected {
                    Circle().fill(.tint)
                } else if isToday {
                    Circle().stroke(.tint, lineWidth: 1.5)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 40)
            .contentShape(.rect)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        ToolbarItem(placement: .title) {
            Text(presenter.currentMonth.formatted(.dateTime.year().month()))
                .font(.headline)
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDismissPressed()
            } label: {
                Image(systemName: "xmark")
            }
            .accessibilityLabel("Close")
        }

        // Grouped so the chevrons read as one control and keep standard toolbar
        // spacing, instead of two 44pt blocks crowding each other.
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                presenter.onTodayPressed()
            } label: {
                Text("Today")
            }
            .disabled(presenter.isViewingCurrentMonth)

            Button {
                presenter.onBackMonthPressed()
            } label: {
                Image(systemName: "chevron.left")
            }
            .accessibilityLabel("Previous month")

            Button {
                presenter.onForwardMonthPressed()
            } label: {
                Image(systemName: "chevron.right")
            }
            .accessibilityLabel("Next month")
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
    static let calendarSheetHeight: CGFloat = 460

    func showCalendarView(delegate: CalendarDelegate) {
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.height(Self.calendarSheetHeight)]))) { router in
            builder.calendarView(router: router, delegate: delegate)
        }
    }

    func showCalendarViewZoom(delegate: CalendarDelegate, onDismiss: (() -> Void)? = nil, transitionId: String?, namespace: Namespace.ID) {
        router.showScreenWithZoomTransition(
            .sheetConfig(config: ResizableSheetConfig(detents: [.height(Self.calendarSheetHeight), .large], dragIndicator: .visible)),
            onDismiss: onDismiss,
            transitionID: transitionId,
            namespace: namespace) { router in
                builder.calendarView(router: router, delegate: delegate)
            }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = CalendarDelegate { date, _ in
        print("Date selected: \(date)")
    }
    Color.clear
        .sheet(isPresented: .constant(true)) {
            RouterView { router in
                builder.calendarView(router: router, delegate: delegate)
            }
            .presentationDetents([.height(CoreRouter.calendarSheetHeight)])
        }
}
