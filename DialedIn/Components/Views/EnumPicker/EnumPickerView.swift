import SwiftUI
import SwiftfulRouting

struct EnumPickerDelegate<Item: PickableItem> {
    let navigationTitle: String
    var chosenItem: Binding<Item?>
    var canDelete: Bool
}

protocol PickableItem: CaseIterable, Hashable {
    var name: String { get }
    var description: String? { get }
}

struct EnumPickerView<Item: PickableItem>: View {
    
    @State var presenter: EnumPickerPresenter
    let delegate: EnumPickerDelegate<Item>
    
    var body: some View {
        List {
            pickerSection
        }
        .navigationTitle(delegate.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "EnumPickerView")
        .toolbar { toolbarContent }
        .scrollIndicators(.hidden)
    }

    private var pickerSection: some View {
        Section {
            ForEach(Array(Item.allCases), id: \.self) { item in
                rowItem(item: item)
            }
        }
        .listSectionMargins(.top, 0)
    }
    
    @ViewBuilder
    func rowItem(item: Item) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                if let description = item.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
                Circle()
                    .stroke(lineWidth: delegate.chosenItem.wrappedValue == item ? 12 : 3)
                    .frame(height: 20)
        }
        .tappableBackground()
        .anyButton(.press) {
            presenter.onSelect(item: item, binding: delegate.chosenItem)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDismissPressed()
            } label: {
                Image(systemName: "xmark")
            }
        }

        if delegate.canDelete {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    presenter.onDeletePressed(binding: delegate.chosenItem)
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }
}

extension CoreBuilder {
    
    func enumPickerView<Item: PickableItem>(router: Router, delegate: EnumPickerDelegate<Item>) -> some View {
        EnumPickerView<Item>(
            presenter: EnumPickerPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showEnumPickerView<Item: PickableItem>(delegate: EnumPickerDelegate<Item>, detentsInput: PresentationDetentTransformable? = nil) {
        if let detentsVerified = detentsInput {
            router.showScreen(.sheetConfig(config: ResizableSheetConfig(
                detents: [detentsVerified]
            ))) { router in
                builder.enumPickerView(router: router, delegate: delegate)
            }
        } else {
            router.showScreen(.sheet) { router in
                builder.enumPickerView(router: router, delegate: delegate)
            }
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = EnumPickerDelegate<TrackableExerciseMetric>(
        navigationTitle: "Trackable Metric 1",
        chosenItem: .constant(TrackableExerciseMetric.reps),
        canDelete: true
    )
    
    return RouterView { router in
        builder.enumPickerView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
