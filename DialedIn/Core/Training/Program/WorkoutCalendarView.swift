//
//  WorkoutCalendarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI

struct WorkoutCalendarView: View {
    
    @State private var isShowingCalendar: Bool = true
    @State private var collapsedSubtitle: String = "No sessions planned yet — tap to plan"
    
    var body: some View {
        Section(isExpanded: $isShowingCalendar) {
            ScheduleView { date in
                collapsedSubtitle = "Next: \(date.formatted(.dateTime.day().month()))"
            }
        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text("Plan")
                if !isShowingCalendar {
                    Text(collapsedSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isShowingCalendar ? 0 : 90))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onCalendarToggled()
            }
            .animation(.easeInOut, value: isShowingCalendar)
        }
    }
    
    private func onCalendarToggled() {
        withAnimation(.easeInOut) {
            isShowingCalendar.toggle()
        }
    }
}

#Preview {
    List {
        WorkoutCalendarView()
    }
    .previewEnvironment()
}
