import SwiftUI
import Charts

extension View {
    @ViewBuilder
    func applyChartXScale(_ domain: ClosedRange<Date>?) -> some View {
        if let domain {
            self.chartXScale(domain: domain)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyChartForegroundStyleScale(_ mapping: [String: Color]?) -> some View {
        if let mapping = mapping {
            let sorted = mapping.sorted { $0.key < $1.key }
            let domain = sorted.map { $0.key }
            let range = sorted.map { $0.value }
            self.chartForegroundStyleScale(domain: domain, range: range)
        } else {
            self
        }
    }

    @ViewBuilder
    func applyChartSymbolScale(_ mapping: [String: AnyChartSymbolShape]?) -> some View {
        if let mapping = mapping {
            let sorted = mapping.sorted { $0.key < $1.key }
            let domain = sorted.map { $0.key }
            let range = sorted.map { $0.value }
            self.chartSymbolScale(domain: domain, range: range)
        } else {
            self
        }
    }
}
