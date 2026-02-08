import SwiftUI
import Charts

struct SparklineConfiguration {
    var lineColor: Color = .accent
    var lineWidth: CGFloat = 2
    var fillColor: Color?
    var height: CGFloat = 40
    var showsPoints: Bool = false
}

struct SparklineChart: View {
    var data: [(date: Date, value: Double)]
    var configuration: SparklineConfiguration = SparklineConfiguration()

    /// Chart needs at least 2 points for LineMark. Single point gets a synthetic prior point.
    private var chartData: [(date: Date, value: Double)] {
        let sorted = data.sorted { $0.date < $1.date }
        guard let first = sorted.first else { return [] }
        if sorted.count == 1, let priorDate = Calendar.current.date(byAdding: .day, value: -1, to: first.date) {
            return [(date: priorDate, value: first.value), first]
        }
        return sorted
    }

    var body: some View {
        Group {
            if data.isEmpty {
                emptyPlaceholder
            } else {
                Chart {
                    let points = chartData
                    ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Value", point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: configuration.lineWidth))
                        .foregroundStyle(configuration.lineColor)

                        if configuration.showsPoints {
                            PointMark(
                                x: .value("Date", point.date),
                                y: .value("Value", point.value)
                            )
                            .foregroundStyle(configuration.lineColor)
                        }
                    }

                    if let fillColor = configuration.fillColor {
                        ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                            AreaMark(
                                x: .value("Date", point.date),
                                y: .value("Value", point.value)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [fillColor.opacity(0.35), fillColor.opacity(0.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .chartLegend(.hidden)
            }
        }
        .frame(height: configuration.height)
    }

    private var emptyPlaceholder: some View {
        GeometryReader { geo in
            Path { path in
                let yVal = geo.size.height * 0.5
                path.move(to: CGPoint(x: 0, y: yVal))
                path.addLine(to: CGPoint(x: geo.size.width, y: yVal))
            }
            .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
    }
}

#Preview("Full data") {
    SparklineChart(
        data: [
            (date: Date.now.addingTimeInterval(-86400 * 6), value: 82.3),
            (date: Date.now.addingTimeInterval(-86400 * 5), value: 82.1),
            (date: Date.now.addingTimeInterval(-86400 * 4), value: 82.4),
            (date: Date.now.addingTimeInterval(-86400 * 3), value: 82.2),
            (date: Date.now.addingTimeInterval(-86400 * 2), value: 82.6),
            (date: Date.now.addingTimeInterval(-86400 * 1), value: 82.5),
            (date: Date.now, value: 82.7)
        ],
        configuration: SparklineConfiguration(fillColor: .accent)
    )
    .frame(height: 36)
    .padding()
}

#Preview("Single point") {
    SparklineChart(
        data: [(date: Date.now, value: 82.5)],
        configuration: SparklineConfiguration(fillColor: .accent)
    )
    .frame(height: 36)
    .padding()
}

#Preview("Empty") {
    SparklineChart(data: [], configuration: SparklineConfiguration(fillColor: .accent))
        .frame(height: 36)
        .padding()
}
