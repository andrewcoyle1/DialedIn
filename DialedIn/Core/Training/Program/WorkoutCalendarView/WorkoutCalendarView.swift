//
//  WorkoutCalendarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI

struct WorkoutCalendarView: View {
    @Environment(TrainingPlanManager.self) private var trainingPlanManager
    @Environment(WorkoutTemplateManager.self) private var workoutTemplateManager
    
    @State private var isShowingCalendar: Bool = true
    @State private var collapsedSubtitle: String = "No sessions planned yet — tap to plan"
    @State private var scheduledWorkouts: [ScheduledWorkout] = []
    @State private var selectedDate: Date?
    @State private var showScheduleSheet: Bool = false
    
    var body: some View {
        Section(isExpanded: $isShowingCalendar) {
            EnhancedScheduleView(
                scheduledWorkouts: scheduledWorkouts,
                onDateSelected: { date in
                    selectedDate = date
                    collapsedSubtitle = "Next: \(date.formatted(.dateTime.day().month()))"
                },
                onDateTapped: { date in
                    selectedDate = date
                    showScheduleSheet = true
                }
            )
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
        .sheet(isPresented: $showScheduleSheet) {
            if let date = selectedDate {
                DayScheduleSheet(date: date, scheduledWorkouts: workoutsForDate(date))
            }
        }
        .onAppear {
            loadScheduledWorkouts()
        }
        .onChange(of: trainingPlanManager.currentTrainingPlan) { _, _ in
            loadScheduledWorkouts()
        }
    }
    
    private func onCalendarToggled() {
        withAnimation(.easeInOut) {
            isShowingCalendar.toggle()
        }
    }
    
    private func loadScheduledWorkouts() {
        guard let plan = trainingPlanManager.currentTrainingPlan else {
            scheduledWorkouts = []
            return
        }
        scheduledWorkouts = plan.weeks.flatMap { $0.scheduledWorkouts }
    }
    
    private func workoutsForDate(_ date: Date) -> [ScheduledWorkout] {
        let calendar = Calendar.current
        return scheduledWorkouts.filter { workout in
            guard let scheduledDate = workout.scheduledDate else { return false }
            return calendar.isDate(scheduledDate, inSameDayAs: date)
        }
    }
}

#Preview {
    List {
        WorkoutCalendarView()
    }
    .previewEnvironment()
}
