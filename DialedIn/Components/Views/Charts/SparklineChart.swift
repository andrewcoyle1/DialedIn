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

    var body: some View {
        Group {
            if data.isEmpty {
                Color.clear
            } else {
                Chart {
                    let sorted = data.sorted { $0.date < $1.date }
                    ForEach(sorted, id: \.date) { point in
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
                        ForEach(sorted, id: \.date) { point in
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
}

#Preview {
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
    .padding()
}
