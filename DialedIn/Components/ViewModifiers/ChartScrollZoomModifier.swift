import SwiftUI
import Charts

struct ChartScrollZoomModifier: ViewModifier {
    @Bindable var state: ChartScrollZoomState
    var axes: Axis.Set

    func body(content: Content) -> some View {
        content
            .chartScrollableAxes(axes)
            .chartScrollPosition(x: $state.scrollPosition)
            .chartXVisibleDomain(length: state.visibleDomainLength)
            .chartOverlay { proxy in
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            let width = proxy.plotFrame.map { geo[$0].size.width } ?? 300
                            state.updatePlotWidth(width)
                        }
                        .onChange(of: proxy.plotFrame.map { geo[$0].size.width } ?? 300) { _, newValue in
                            state.updatePlotWidth(newValue)
                        }
                }
            }
            .chartGesture { _ in
                magnifyGesture
            }
            .onChange(of: state.scrollPosition) { _, _ in
                state.notifyVisibleRangeChanged()
            }
            .onChange(of: state.totalZoomDays) { _, _ in
                state.notifyVisibleRangeChanged()
            }
    }

    private var magnifyGesture: some Gesture {
        MagnifyGesture(minimumScaleDelta: 0.0)
            .onChanged { value in
                state.handleMagnificationChanged(value.magnification)
            }
            .onEnded { _ in
                state.handleMagnificationEnded()
            }
    }
}

extension Chart {
    func scrollableAndMagnifiable(
        state: ChartScrollZoomState,
        axes: Axis.Set = [.horizontal]
    ) -> some View {
        modifier(ChartScrollZoomModifier(state: state, axes: axes))
    }
}
