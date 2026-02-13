import SwiftUI

struct BodyMetricCardView: View {
    let card: BodyMetricCardModel
    let themeColor: Color
    let onPress: () -> Void

    var body: some View {
        DashboardCard(
            title: card.title,
            subtitle: card.subtitle,
            subsubtitle: card.latestValueText,
            subsubsubtitle: card.unitText,
            themeColor: themeColor,
            chartConfiguration: DashboardCardChartConfiguration(height: 36, verticalPadding: 2)
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
