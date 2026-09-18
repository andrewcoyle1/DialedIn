import SwiftUI

struct BodyMetricsDelegate {

}

struct BodyMetricsView: View {

    @State var presenter: BodyMetricsPresenter
    let delegate: BodyMetricsDelegate

    private let bodyMetricsColor = Color.green

    var body: some View {
        List {
            Group {
                dataDrivenSection(presenter.sections[0])
                dataDrivenSection(presenter.sections[1])
                dataDrivenSection(presenter.sections[2])
                dataDrivenSection(presenter.sections[3])
                ratiosSection
            }
            .listSectionMargins(.horizontal, 0)
            .listRowSeparator(.hidden)
        }
        .navigationTitle("Body Metrics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .close) {
                    presenter.onDismissPressed()
                }
            }
        }
    }

    private func dataDrivenSection(_ section: BodyMetricsSection) -> some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(section.cards) { card in
                    BodyMetricCardView(card: card, themeColor: bodyMetricsColor) {
                        presenter.onMeasurementPressed(card.id, themeColor: bodyMetricsColor)
                    }
                }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text(section.header)
        }
    }

    // A "Visual & Metric Overview" section used to sit here, showing a "No Photos" placeholder
    // beside an invented "Full Body / 12 Jan 2026 / 1 metric" card, neither of which did anything.
    // Removed rather than rebuilt: `BodyMeasurementEntry.progressPhotoURLs` is stored and synced,
    // but no screen in the app reads it, so there is no gallery for a photo card to open. The
    // visual body fat metric it seemed to duplicate is already a real card in the first section.
    // Building progress photos means a gallery screen and a capture flow — a feature, not a fix.

    /// Waist-to-height and waist-to-hip, both computed from logged measurements. Tapping opens the
    /// ratio's history on the shared `MetricDetailView`, the same as every measured card here.
    private var ratiosSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(presenter.ratioCards) { card in
                    BodyRatioCardView(card: card, themeColor: bodyMetricsColor) {
                        presenter.onRatioPressed(card.id, themeColor: bodyMetricsColor)
                    }
                }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Ratios")
        }
    }
}

extension CoreBuilder {

    func bodyMetricsView(router: AnyRouter, delegate: BodyMetricsDelegate) -> some View {
        BodyMetricsView(
            presenter: BodyMetricsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {

    func showBodyMetricsView(delegate: BodyMetricsDelegate) {
        router.showScreen(.sheet) { router in
            builder.bodyMetricsView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = BodyMetricsDelegate()

    return RouterView { router in
        builder.bodyMetricsView(router: router, delegate: delegate)
    }
    
}
