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
    let delegate: CalendarDelegate

    var body: some View {
        VStack {

            // Days of the week row
            daysOfWeekHeader

            // Grid of days
            dayGrid

        }
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal)
        .toolbar {
            toolbarContent
        }
    }

    private var daysOfWeekHeader: some View {
        HStack {
            ForEach(presenter.daysOfWeek.indices, id: \.self) { index in
                Text(presenter.daysOfWeek[index])
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var dayGrid: some View {
        LazyVGrid(columns: presenter.columns, spacing: 10) {
            ForEach(presenter.days, id: \.self) { day in
                Button {
                    if day >= Date.now.startOfDay && day.monthInt == presenter.currentMonth.monthInt {
                        presenter.onDateSelected(day: day, do: delegate.onDateSelected)
                    }
                } label: {
                    Text(day.formatted(.dateTime.day()))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(presenter.foregroundStyle(for: day))
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .contentShape(Rectangle())
                        .background(
                            Circle()
                                .fill(
                                    day.formattedDate == presenter.selectedDate.formattedDate
                                    ? Color.accentColor
                                    : Color.clear
                                )
                        )
                }
                .disabled(day < Date.now.startOfDay || day.monthInt != presenter.currentMonth.monthInt)
            }
        }
        .buttonStyle(.plain)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        ToolbarItem(placement: .title) {
            Text(presenter.currentMonth.formatted(.dateTime.year().month()))
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.primary)
        }
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDismissPressed()
            } label: {
                Image(systemName: "xmark")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onBackMonthPressed()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundStyle(.tint)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onForwardMonthPressed()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundStyle(.tint)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
        }
    }

}

extension CoreBuilder {

    func calendarView(router: Router, delegate: CalendarDelegate) -> some View {
        CalendarView(
            presenter: CalendarPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {

    func showCalendarView(delegate: CalendarDelegate) {
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.45)]))) { router in
            builder.calendarView(router: router, delegate: delegate)
        }
    }

    func showCalendarViewZoom(delegate: CalendarDelegate, transitionId: String?, namespace: Namespace.ID) {
        router.showScreenWithZoomTransition(
            .sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.45)])),
            transitionID: transitionId,
            namespace: namespace) { router in
                builder.calendarView(router: router, delegate: delegate)
            }

    }

}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    let delegate = CalendarDelegate { date, _ in
        print("Date selected: \(date)")
    }
    Color.clear
        .sheet(isPresented: .constant(true)) {
            RouterView { router in
                builder.calendarView(router: router, delegate: delegate)
            }
            .presentationDetents([.fraction(0.45)])
        }
        .previewEnvironment()
}
