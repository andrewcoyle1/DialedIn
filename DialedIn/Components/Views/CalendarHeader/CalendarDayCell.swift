//
//  CalendarDayCell.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/09/2026.
//

import SwiftUI

/// One day, shared by the week strip in `CalendarHeaderView` and the month grid in
/// `CalendarView`, so the two cannot drift apart. The expanded calendar used a plain circle
/// and no activity badge, which read as a different component entirely.
struct CalendarDayCell: View {

    @Environment(\.colorScheme) private var colorScheme

    let day: Date
    let activityCount: Int
    let isToday: Bool
    let isSelected: Bool

    /// The week strip labels each column; the month grid has its own weekday header row.
    var showsWeekday: Bool = false

    var body: some View {
        VStack(spacing: 2) {
            if showsWeekday {
                Text(day.formatted(.dateTime.weekday(.narrow)))
                    .font(.caption2)
                    .foregroundStyle(isSelected ? AnyShapeStyle(colorScheme.backgroundPrimary) : AnyShapeStyle(.secondary))
            }
            Text(day.formatted(.dateTime.day()))
                .font(.subheadline)
                .foregroundStyle(dayNumberStyle)

            todayDot
        }
        .monospaced()
        .fontWeight(isSelected || isToday ? .semibold : .regular)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background {
            outline
                .padding(.horizontal, 4)
        }
        .overlay(alignment: .topTrailing) {
            if activityCount > 1 {
                badge
            }
        }
        .contentShape(.rect)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    /// Always in the layout, only visible for today — an `if` here would make today's cell
    /// taller than its neighbours and knock the row out of alignment.
    private var todayDot: some View {
        Circle()
            .fill(isToday ? todayDotStyle : AnyShapeStyle(.clear))
            .frame(width: 4, height: 4)
    }

    /// Inverted on the selected cell, which is filled with the tint the dot would otherwise use.
    private var todayDotStyle: AnyShapeStyle {
        isSelected ? AnyShapeStyle(colorScheme.backgroundPrimary) : AnyShapeStyle(.tint)
    }

    private var dayNumberStyle: AnyShapeStyle {
        if isSelected {
            return AnyShapeStyle(colorScheme.backgroundPrimary)
        } else if isToday {
            return AnyShapeStyle(Color.accentColor)
        } else {
            return AnyShapeStyle(.primary)
        }
    }

    @ViewBuilder
    private var outline: some View {
        Capsule()
            .fill(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(colorScheme.backgroundPrimary))
            .overlay {
                if isSelected {
                    Capsule()
                        .stroke(colorScheme.backgroundSecondary, lineWidth: 2)
                } else if activityCount > 0 {
                    // Today is marked by the dot under the number, not by this stroke — the two
                    // looked identical, so there was no telling which cells had a workout to
                    // open and which would do nothing when tapped.
                    Capsule()
                        .stroke(.tint, lineWidth: 2)
                } else {
                    Capsule()
                        .stroke(.secondary.opacity(0.5), lineWidth: 2)
                }
            }
    }

    private var badge: some View {
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

#Preview {
    let today = Date()

    return VStack(spacing: 24) {
        // today · today+selected · one workout · several workouts · plain
        HStack(spacing: 0) {
            CalendarDayCell(day: today, activityCount: 0, isToday: true, isSelected: false, showsWeekday: true)
            CalendarDayCell(day: today, activityCount: 0, isToday: true, isSelected: true, showsWeekday: true)
            CalendarDayCell(day: today, activityCount: 1, isToday: false, isSelected: false, showsWeekday: true)
            CalendarDayCell(day: today, activityCount: 3, isToday: false, isSelected: false, showsWeekday: true)
            CalendarDayCell(day: today, activityCount: 0, isToday: false, isSelected: false, showsWeekday: true)
        }

        HStack(spacing: 0) {
            CalendarDayCell(day: today, activityCount: 0, isToday: true, isSelected: false)
            CalendarDayCell(day: today, activityCount: 0, isToday: true, isSelected: true)
            CalendarDayCell(day: today, activityCount: 1, isToday: false, isSelected: false)
            CalendarDayCell(day: today, activityCount: 12, isToday: false, isSelected: false)
            CalendarDayCell(day: today, activityCount: 0, isToday: false, isSelected: false)
        }
    }
    .padding()
}
