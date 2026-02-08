//
//  ContributionChartView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 14/08/2025.
//

import SwiftUI

struct ContributionChartView: View {
    
    var data: [Double]
    var rows: Int
    var columns: Int
    var targetValue: Double
    var blockColor: Color = Color.green
    var blockBackgroundColor: Color = Color.background
    
    var heatMapRectangleWidth: CGFloat = 20.0
    var heatMapRectangleSpacing: CGFloat = 2.0
    var heatMapRectangleRadius: CGFloat = 5.0
    private let dayLabelColumnWidth: CGFloat = 20.0
    var showsCaptioning: Bool = true
    // Calendar properties for proper date mapping
    private let calendar = Calendar.current
    private let startDate: Date
    private let endDate: Date
    
    public init(data: [Double], rows: Int, columns: Int, targetValue: Double, blockColor: Color = Color.green, blockBackgroundColor: Color, rectangleWidth: CGFloat = 20.0, rectangleSpacing: CGFloat = 2.0, rectangleRadius: CGFloat = 5.0, endDate: Date = Date(), showsCaptioning: Bool = true) {
        // Validate inputs
        let validRows = max(1, rows)
        let validColumns = max(1, columns)
        let validTargetValue = max(0.1, targetValue)
        
        self.data = data
        self.rows = validRows
        self.columns = validColumns
        self.targetValue = validTargetValue
        self.blockColor = blockColor
        self.blockBackgroundColor = blockBackgroundColor
        self.heatMapRectangleWidth = rectangleWidth
        self.heatMapRectangleSpacing = rectangleSpacing
        self.heatMapRectangleRadius = rectangleRadius
        
        // Calculate start date based on total days (rows * columns)
        // Days flow continuously from left to right, with each column containing 'rows' consecutive days
        self.endDate = endDate
        let endDayStart = calendar.startOfDay(for: endDate)
        let totalDays = validRows * validColumns
        self.startDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: endDayStart) ?? endDayStart
        self.showsCaptioning = showsCaptioning
    }
    
    public init(data: [Double], rows: Int, columns: Int, targetValue: Double, blockColor: Color = Color.green, rectangleWidth: CGFloat = 20.0, rectangleSpacing: CGFloat = 2.0, rectangleRadius: CGFloat = 5.0, endDate: Date = Date(), showsCaptioning: Bool = true) {
        // Validate inputs
        let validRows = max(1, rows)
        let validColumns = max(1, columns)
        let validTargetValue = max(0.1, targetValue)
        
        self.data = data
        self.rows = validRows
        self.columns = validColumns
        if data.count < validRows * validColumns {
            let elementsToAdd = Array(repeating: 0.0, count: validRows * validColumns - data.count)
            self.data.append(contentsOf: elementsToAdd)
        }
        self.targetValue = validTargetValue
        self.blockColor = blockColor
        self.heatMapRectangleWidth = rectangleWidth
        self.heatMapRectangleSpacing = rectangleSpacing
        self.heatMapRectangleRadius = rectangleRadius
        
        // Calculate week-aligned start date (weeks start on Sunday)
        self.endDate = endDate
        let endDayStart = calendar.startOfDay(for: endDate)
        let endWeekday = calendar.component(.weekday, from: endDayStart) // Sunday = 1
        let daysBackToSunday = endWeekday - 1
        let endWeekStartSunday = calendar.date(byAdding: .day, value: -daysBackToSunday, to: endDayStart) ?? endDayStart
        self.startDate = calendar.date(byAdding: .day, value: -7 * (validColumns - 1), to: endWeekStartSunday) ?? endWeekStartSunday
        self.showsCaptioning = showsCaptioning

    }
    
    public var body: some View {
        VStack(spacing: CGFloat(heatMapRectangleSpacing)) {
            if showsCaptioning {
                statisticsSection
            }
            
            chartSection
            
            if showsCaptioning {
                // Date range indicator
                Text(dateRangeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 2)
                
                legendSection
            }
        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.background)
//                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
//        )
        .animation(.easeInOut(duration: 0.3), value: data)
        .accessibilityElement(children: .combine)
    }
    
    private var statisticsSection: some View {
        // Summary statistics
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("Study Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text("\(currentStreak) days")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(currentStreak > 0 ? .orange : .gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Completion Rate")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(completionRate, specifier: "%.0f")%")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(completionRateColor)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    private var chartSection: some View {
        // Chart
        GeometryReader { geo in
            let spacing = CGFloat(heatMapRectangleSpacing)
            let monthLabelHeight: CGFloat = showsCaptioning ? 16 : 0
            let dayLabelWidth: CGFloat = showsCaptioning ? dayLabelColumnWidth + spacing : 0
            let availableChartWidth = max(0, geo.size.width - dayLabelWidth)
            let cellWidthFromWidth = max(2, (availableChartWidth - CGFloat(max(0, columns - 1)) * spacing) / CGFloat(max(1, columns)))
            let availableChartHeight = max(0, geo.size.height - monthLabelHeight - (showsCaptioning ? spacing : 0))
            let cellHeightFromHeight = max(2, (availableChartHeight - CGFloat(max(0, rows - 1)) * spacing) / CGFloat(max(1, rows)))
            
            // Prioritize filling available width, but respect height constraints
            // Allow rectangular cells when needed to fill the available space
            let cellWidth = cellWidthFromWidth
            let cellHeight = min(cellWidth, cellHeightFromHeight) // Prefer square, but allow rectangular if needed
            
            let chartHeight = monthLabelHeight + (showsCaptioning ? spacing : 0) + (CGFloat(rows) * cellHeight) + (CGFloat(max(0, rows - 1)) * spacing)
            HStack(alignment: .top, spacing: spacing) {
                if showsCaptioning {
                    // Day labels
                    VStack(spacing: spacing) {
                        ForEach(0..<rows, id: \.self) { rowIndex in
                            Text(dayLabel(for: rowIndex))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(width: dayLabelColumnWidth, height: cellHeight, alignment: .center)
                        }
                    }
                    .frame(height: (CGFloat(rows) * cellHeight) + (CGFloat(max(0, rows - 1)) * spacing), alignment: .top)
                    .padding(.top, monthLabelHeight + spacing)
                    
                }
                // Chart
                ZStack {
                    VStack(spacing: spacing) {
                        if showsCaptioning {
                            // Month labels
                            HStack(spacing: spacing) {
                                ForEach(0..<columns, id: \.self) { columnIndex in
                                    let showLabel = shouldShowMonthLabel(for: columnIndex)
                                    Text(showLabel ? monthLabel(for: columnIndex) : "")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                        .allowsTightening(true)
                                        .frame(width: cellWidth, height: monthLabelHeight, alignment: .center)
                                }
                            }
                            .frame(height: monthLabelHeight, alignment: .top)
                        }
                        // Chart grid
                        HStack(spacing: spacing) {
                            ForEach(0..<columns, id: \.self) { columnIndex in
                                let start = columnIndex * rows
                                let end = min((columnIndex + 1) * rows, data.count)
                                let splitedData = start < data.count ? Array(data[start..<end]) : []
                                ContributionChartRowView(
                                    rowData: splitedData,
                                    rows: rows,
                                    targetValue: targetValue,
                                    blockColor: blockColor,
                                    blockBackgroundColor: blockBackgroundColor,
                                    heatMapRectangleWidth: cellWidth,
                                    heatMapRectangleHeight: cellHeight,
                                    heatMapRectangleSpacing: spacing,
                                    heatMapRectangleRadius: heatMapRectangleRadius,
                                    columnStartDate: columnStartDate(for: columnIndex)
                                )
                            }
                        }
                        .frame(height: (CGFloat(rows) * cellHeight) + (CGFloat(max(0, rows - 1)) * spacing), alignment: .top)
                    }
                }
            }
            .frame(width: geo.size.width, height: chartHeight, alignment: .leading)
        }
    }
    
    private var legendSection: some View {
        // Legend
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 12, height: 12)
                    .foregroundColor(blockColor.opacity(0.1))
                Text("0%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 12, height: 12)
                    .foregroundColor(blockColor.opacity(0.5))
                Text("50%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 12, height: 12)
                    .foregroundColor(blockColor)
                Text("100%+")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 4)
    }
    
    private func dayLabel(for rowIndex: Int) -> String {
        // Calculate the actual day of week for the first row (row 0) of the first column
        // Then add rowIndex to get the day for this row
        let firstRowDate = dateForCell(columnIndex: 0, rowIndex: rowIndex)
        let weekday = calendar.component(.weekday, from: firstRowDate) // Sunday = 1, Monday = 2, etc.
        let days = ["S", "M", "T", "W", "T", "F", "S"]
        // weekday is 1-based (Sunday=1), array is 0-based
        return days[(weekday - 1) % 7]
    }
    
    private func monthLabel(for columnIndex: Int) -> String {
        let columnStart = columnStartDate(for: columnIndex)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: columnStart)
    }

    private func shouldShowMonthLabel(for columnIndex: Int) -> Bool {
        let currentColumnStart = columnStartDate(for: columnIndex)
        let previousColumnStart: Date? = columnIndex > 0 ? columnStartDate(for: columnIndex - 1) : nil
        let nextColumnStart: Date? = columnIndex < columns - 1 ? columnStartDate(for: columnIndex + 1) : nil
        let isFirstColumn = columnIndex == 0
        let monthChangedFromPrev: Bool
        if let prev = previousColumnStart {
            monthChangedFromPrev = calendar.component(.month, from: currentColumnStart) != calendar.component(.month, from: prev)
        } else {
            monthChangedFromPrev = false
        }
        let monthChangedToNext: Bool
        if let next = nextColumnStart {
            monthChangedToNext = calendar.component(.month, from: currentColumnStart) != calendar.component(.month, from: next)
        } else {
            monthChangedToNext = false
        }
        // Show at month boundaries; skip first-column label if the next column is also a boundary to avoid adjacent labels
        if monthChangedFromPrev { return true }
        if isFirstColumn { return !monthChangedToNext }
        return false
    }
    
    /// Calculates the start date for a specific column
    /// Each column contains 'rows' consecutive days
    private func columnStartDate(for columnIndex: Int) -> Date {
        let dayOffset = columnIndex * rows
        return calendar.date(byAdding: .day, value: dayOffset, to: startDate) ?? startDate
    }
    
    /// Calculates the actual date for a specific cell position
    /// - Parameters:
    ///   - columnIndex: Column index (0-based)
    ///   - rowIndex: Row index within the column (0-based)
    /// - Returns: The actual date for this cell
    private func dateForCell(columnIndex: Int, rowIndex: Int) -> Date {
        let dayOffset = columnIndex * rows + rowIndex
        return calendar.date(byAdding: .day, value: dayOffset, to: startDate) ?? startDate
    }
    
    /// Debug method to print the date mapping
    private func printDateMapping() {
        print("Contribution Chart Date Mapping:")
        print("Start Date: \(startDate)")
        print("End Date: \(endDate)")
        print("Total Days: \(rows * columns)")
        print("Data Count: \(data.count)")
        
        for column in 0..<columns {
            for row in 0..<rows {
                let date = dateForCell(columnIndex: column, rowIndex: row)
                let dataIndex = column * rows + row
                let value = dataIndex < data.count ? data[dataIndex] : 0.0
                print("Column \(column), Row \(row): \(date) -> Value: \(value)")
            }
        }
    }
    
    /// The end date of the chart
    
    /// The date range string for debugging
    private var dateRangeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: startDate)) to \(formatter.string(from: endDate))"
    }
    
    /// Calculates the current study streak
    private var currentStreak: Int {
        var streak = 0
        var currentDate = endDate
        
        while streak < data.count {
            let dataIndex = data.count - 1 - streak
            if dataIndex >= 0 && data[dataIndex] > 0 {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    /// Calculates the overall completion rate
    private var completionRate: Double {
        let completedDays = data.filter { $0 > 0 }.count
        return data.isEmpty ? 0.0 : (Double(completedDays) / Double(data.count)) * 100.0
    }
    
    /// Determines the color for the completion rate based on its value
    private var completionRateColor: Color {
        switch completionRate {
        case 0..<50:
            return Color.red
        case 50..<75:
            return Color.orange
        case 75..<100:
            return Color.yellow
        case 100...:
            return Color.green
        default:
            return Color.gray
        }
    }
}

#Preview("Contribution Chart") {
    // Sample data: 7 rows x 16 columns
    let rows = 7
    let columns = 16
    let sampleData: [Double] = (0..<(rows * columns)).map { _ in Double.random(in: 0...1.2) }
    return List {
        Section {
            ContributionChartView(
                data: sampleData,
                rows: rows,
                columns: columns,
                targetValue: 1.0,
                blockColor: .accent,
                blockBackgroundColor: .secondaryBackground,
                rectangleWidth: 16,
                rectangleSpacing: 2,
                rectangleRadius: 3
            )
            .frame(minHeight: 190)
        } header: {
            Text("Contribution Chart")
        }
    }
}

struct ContributionChartRowView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var rowData: [Double]
    var rows: Int
    var targetValue: Double
    var blockColor: Color
    var blockBackgroundColor: Color
    var heatMapRectangleWidth: CGFloat
    var heatMapRectangleHeight: CGFloat?
    var heatMapRectangleSpacing: CGFloat
    var heatMapRectangleRadius: CGFloat
    var columnStartDate: Date
    
    private let calendar = Calendar.current
    
    private var rectangleHeight: CGFloat {
        heatMapRectangleHeight ?? heatMapRectangleWidth
    }
    
    var body: some View {
        VStack(spacing: CGFloat(heatMapRectangleSpacing)) {
            ForEach(0..<rows, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: CGFloat(heatMapRectangleRadius))
                        .frame(width: CGFloat(heatMapRectangleWidth), height: CGFloat(rectangleHeight), alignment: .center
                        )
                        .foregroundColor(blockBackgroundColor)
                    RoundedRectangle(cornerRadius: CGFloat(heatMapRectangleRadius))
                        .frame(width: CGFloat(heatMapRectangleWidth), height: CGFloat(rectangleHeight), alignment: .center)
                        .foregroundColor(blockColor
                            .opacity(CGFloat(opacityRatio(index: index))))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: CGFloat(heatMapRectangleRadius))
                        .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
                        .frame(width: CGFloat(heatMapRectangleWidth), height: CGFloat(rectangleHeight))
                )
                .accessibilityLabel(accessibilityLabel(for: index))
                .scaleEffect(opacityRatio(index: index) > 0 ? CGFloat(1.0) : CGFloat(0.95))
                .animation(.easeInOut(duration: 0.1), value: opacityRatio(index: index))
            }
        }
    }
    
    func opacityRatio(index: Int) -> Double {
        guard index >= 0 && index < rowData.count else { return 0.0 }
        let opacityRatio: Double = Double(rowData[index]) / Double(targetValue)
        return opacityRatio > 1.0 ? 1.0 : opacityRatio
    }
    
    private func accessibilityLabel(for index: Int) -> String {
        guard index >= 0 && index < rowData.count else { return "Invalid date" }
        // Each row in the column represents consecutive days starting from columnStartDate
        let date = calendar.date(byAdding: .day, value: index, to: columnStartDate) ?? columnStartDate
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let dateString = formatter.string(from: date)
        let value = rowData[index]
        let percentage = Int(value * 100)
        return "\(dateString): \(percentage)% of daily goal"
    }
}

extension Color {
    init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (red, green, blue) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (red, green, blue) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (red, green, blue) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (red, green, blue) = (0, 0, 0)
        }
        self.init(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
    }
    #if os(macOS)
    static let background = Color(NSColor.windowBackgroundColor)
    static let secondaryBackground = Color(NSColor.underPageBackgroundColor)
    static let tertiaryBackground = Color(NSColor.controlBackgroundColor)
    #endif
    #if os(iOS)
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    #endif
    #if os(watchOS)
    static let background = Color.black
    #endif
}
