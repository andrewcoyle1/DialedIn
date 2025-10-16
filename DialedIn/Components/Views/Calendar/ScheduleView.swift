//
//  CustomCalendar.swift
//  DialedIn
//
//  Created by Andrew Coyle on 16/10/2025.
//

import SwiftUI

struct ScheduleView: View {
    
    @State private var selectedSessionDate: Date = Date.now
    @State private var selectedSessionHour: Date = Date.now
    
    var onDateSelected: (Date) -> Void
    
    var body: some View {
        VStack {
            CalendarView { selectedDate, selectedHour in
                self.selectedSessionDate = selectedDate
                self.selectedSessionHour = selectedHour
                let combinedDate = Calendar.current.date(
                                    bySettingHour: selectedHour.hourInt,
                                    minute: selectedHour.minuteInt,
                                    second: 0,
                                    of: selectedDate
                                ) ?? selectedDate
                                
                                onDateSelected(combinedDate)
            }
            
            // HStack {
            //  Spacer()
            //  Button {
            //      let combinedDate = Calendar.current.date(
            //          bySettingHour: selectedSessionHour.hourInt,
            //           minute: selectedSessionHour.minuteInt,
            //          second: 0,
            //          of: selectedSessionDate
            //      ) ?? selectedSessionDate
                    
            //      onDateSelected(combinedDate.formattedDateHourCombined)
            //  } label: {
            //      Image(systemName: "checkmark")
            //          .resizable()
            //          .renderingMode(.template)
            //          .frame(width: 10, height: 10)
            //          .foregroundStyle(.blue)
            //          .padding(8)
            //          .background(
            //              Circle()
            //                  .stroke(.blue, lineWidth: 2)
            //                  .fill(.blue.opacity(0.1))
            //          )
            //  }
            //}
        }
    }
}

#Preview {
    ScheduleView { date in
        print("Date selected: \(date)")
    }
    .padding()
}
