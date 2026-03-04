import SwiftUI

struct TimelineActionsDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct TimelineActionsView: View {
    
    @State var presenter: TimelineActionsPresenter
    let delegate: TimelineActionsDelegate
    
    var body: some View {
        List {
            Section {
                CustomLabelButtonView(symbolName: "pages", title: "Copy Day") { EmptyView() }
                CustomLabelButtonView(symbolName: "checkmark.circle.fill", title: "Select All") { EmptyView() }
                CustomLabelButtonView(symbolName: "trash", title: "Clear Day") { EmptyView() }
                CustomToggleView(symbolName: "chevron.up", title: "Hide Food Details", bool: .constant(false))
                CustomToggleView(symbolName: "hourglass", title: "Hide Empty Hours", bool: .constant(false))
            }
            .listSectionMargins(.top, 0)
        }
        .navigationTitle("Timeline Actions")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = TimelineActionsDelegate()
    
    return RouterView { router in
        builder.timelineActionsView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func timelineActionsView(router: AnyRouter, delegate: TimelineActionsDelegate) -> some View {
        TimelineActionsView(
            presenter: TimelineActionsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showTimelineActionsView(delegate: TimelineActionsDelegate) {
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.4)]))) { router in
            builder.timelineActionsView(router: router, delegate: delegate)
        }
    }
    
}
