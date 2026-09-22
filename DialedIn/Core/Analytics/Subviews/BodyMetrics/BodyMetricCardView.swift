import SwiftUI

struct BodyMetricCardView: View {
    let card: BodyMetricCardModel
    let themeColor: Color
    let onPress: () -> Void

    var body: some View {
        AnalyticsCard(
            title: card.title,
            subtitle: card.subtitle,
            subsubtitle: card.latestValueText,
            subsubsubtitle: card.unitText,
            themeColor: themeColor,
            chartConfiguration: AnalyticsCardChartConfiguration(height: 36, verticalPadding: 2)
        ) {
            SparklineChart(
                data: card.sparklineData,
                configuration: SparklineConfiguration(
                    lineColor: themeColor,
                    lineWidth: 2,
                    fillColor: themeColor,
                    height: 36
                )
            )
        }
        .tappableBackground()
        .anyButton(.press) { onPress() }
    }
}

/// The same card for a derived ratio. A ratio has no unit, so `subsubsubtitle` is omitted rather
/// than filled with something.
struct BodyRatioCardView: View {
    let card: BodyRatioCardModel
    let themeColor: Color
    let onPress: () -> Void

    var body: some View {
        AnalyticsCard(
            title: card.title,
            subtitle: card.subtitle,
            subsubtitle: card.latestValueText,
            subsubsubtitle: nil,
            themeColor: themeColor,
            chartConfiguration: AnalyticsCardChartConfiguration(height: 36, verticalPadding: 2)
        ) {
            SparklineChart(
                data: card.sparklineData,
                configuration: SparklineConfiguration(
                    lineColor: themeColor,
                    lineWidth: 2,
                    fillColor: themeColor,
                    height: 36
                )
            )
        }
        .tappableBackground()
        .anyButton(.press) { onPress() }
    }
}
