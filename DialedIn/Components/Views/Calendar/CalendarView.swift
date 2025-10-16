//
//  CalendarView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI

struct CalendarView: View {
    
    @State private var currentMonth: Date = Date.now
    @State private var selectedDate: Date = Date.now
    @State private var selectedHour: Date = Date.now
    @State private var days: [Date] = []
    
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var onDateSelected: (Date, Date) -> Void
    
    var body: some View {
        VStack {
            // Month navigation
            HStack {
                Text(currentMonth.formatted(.dateTime.year().month()))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.primary)
                Spacer()
                Button {
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth)!
                    updateDays()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.tint)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Button {
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth)!
                    updateDays()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundStyle(.tint)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 4)
            
            // Days of the week row
            HStack {
                ForEach(daysOfWeek.indices, id: \.self) { index in
                    Text(daysOfWeek[index])
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Grid of days
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(days, id: \.self) { day in
                    Button {
                        if day >= Date.now.startOfDay && day.monthInt == currentMonth.monthInt {
                            selectedDate = day
                            onDateSelected(day, selectedHour)
                        }
                    } label: {
                        Text(day.formatted(.dateTime.day()))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(foregroundStyle(for: day))
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .contentShape(Rectangle())
                            .background(
                                Circle()
                                    .fill(
                                        day.formattedDate == selectedDate.formattedDate
                                        ? Color.accentColor
                                        : Color.clear
                                    )
                            )
                    }
                    .disabled(day < Date.now.startOfDay || day.monthInt != currentMonth.monthInt)
                }
            }
            .buttonStyle(.plain)
            
//            // Time picker
//            DatePicker(
//                "",
//                selection: $selectedHour,
//                displayedComponents: [.hourAndMinute]
//            )
//            .onChange(of: selectedHour) {
//                onDateSelected(selectedDate, selectedHour)
//            }
//            .datePickerStyle(.compact)
//            .datePickerStyle(GraphicalDatePickerStyle())
//            .colorMultiply(.white)
//            .environment(\.colorScheme, .dark)
        }
        // .padding()
        .onAppear {
            updateDays()
            onDateSelected(selectedDate, selectedHour)
        }
    }
    
    private func updateDays() {
        days = currentMonth.calendarDisplayDays
    }
    
    private func foregroundStyle(for day: Date) -> Color {
        let isDifferentMonth = day.monthInt != currentMonth.monthInt
        let isSelectedDate = day.formattedDate == selectedDate.formattedDate
        let isPastDate = day < Date.now.startOfDay
        
        if isDifferentMonth {
            return .secondary
        } else if isPastDate {
            return .secondary
        } else if isSelectedDate {
            return .white
        } else {
            return .primary
        }
    }
}

#Preview {
    CalendarView { date, _ in
        print("Date selected: \(date)")
    }
}
