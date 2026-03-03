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
                visualMetricSection
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

    private var visualMetricSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                AnalyticsCard(title: nil, subtitle: nil, subsubtitle: "No Photos", subsubsubtitle: nil) {
                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .tappableBackground()
                .anyButton(.press) { }
                AnalyticsCard(title: "Full Body", subtitle: "12 Jan 2026", subsubtitle: "1", subsubsubtitle: "metric")
                    .tappableBackground()
                    .anyButton(.press) { }
            }
            .padding(.horizontal)
            .removeListRowFormatting()
        } header: {
            Text("Visual & Metric Overview")
        }
    }

    private var ratiosSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                AnalyticsCard(title: "Waist to Height", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: nil)
                    .tappableBackground()
                    .anyButton(.press) { }
                AnalyticsCard(title: "Waist to Hip", subtitle: "Last 7 Entries", subsubtitle: "---", subsubsubtitle: nil)
                    .tappableBackground()
                    .anyButton(.press) { }
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
