import SwiftUI

struct EquipmentPickerDelegate<Item: ResistanceEquipment> {
    let items: [Item]
    let headerTitle: String
    var chosenItem: Binding<[Item]>
    
    init(
        items: [Item],
        headerTitle: String = "Equipment",
        chosenItem: Binding<[Item]>
    ) {
        self.items = items
        self.headerTitle = headerTitle
        self.chosenItem = chosenItem
    }
}

protocol ResistanceEquipment: Hashable {
    var name: String { get }
    var imageName: String? { get }
}

struct EquipmentPickerView<Item: ResistanceEquipment>: View {
    
    @State var presenter: EquipmentPickerPresenter
    let delegate: EquipmentPickerDelegate<Item>
    @Binding private var chosenItems: [Item]
    
    init(presenter: EquipmentPickerPresenter, delegate: EquipmentPickerDelegate<Item>) {
        self.presenter = presenter
        self.delegate = delegate
        self._chosenItems = delegate.chosenItem
    }
    
    var body: some View {
        List {
            freeWeightsSection
        }
        .navigationTitle("Resistance")
        .navigationSubtitle("Choose One")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "EquipmentPickerView")
        .toolbar {
            toolbarContent
        }
    }
    
    private var freeWeightsSection: some View {
        Section {
            ForEach(delegate.items, id: \.self) { item in
                rowItem(item: item)
            }
        } header: {
            Text(delegate.headerTitle)
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                presenter.onDismissPressed()
            } label: {
                Image(systemName: "xmark")
            }
        }
    }
    
    @ViewBuilder
    private func rowItem(item: Item) -> some View {
        HStack {
            if let imageName = item.imageName {
                ImageLoaderView(urlString: imageName)
                    .frame(width: 40, height: 40)
            } else {
                Rectangle()
                    .foregroundStyle(.secondary.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .cornerRadius(8)
            }

            VStack(alignment: .leading) {
                Text(item.name)
            }
            Spacer()
            Circle()
                .stroke(lineWidth: chosenItems.contains(item) ? 12 : 3)
                .frame(height: 20)
                .labelsHidden()
        }
        .tappableBackground()
        .anyButton(.press) {
            presenter.onSelect(item: item, binding: $chosenItems)
        }
    }
}

extension CoreBuilder {
    
    func equipmentPickerView<Item: ResistanceEquipment>(router: Router, delegate: EquipmentPickerDelegate<Item>) -> some View {
        EquipmentPickerView<Item>(
            presenter: EquipmentPickerPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showEquipmentPickerView<Item: ResistanceEquipment>(delegate: EquipmentPickerDelegate<Item>) {
        router.showScreen(.sheet) { router in
            builder.equipmentPickerView(router: router, delegate: delegate)
        }
    }
    
}

extension FreeWeights: @MainActor ResistanceEquipment { }

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = EquipmentPickerDelegate<FreeWeights>(
        items: GymProfileModel.mock.freeWeights,
        headerTitle: "Free Weights",
        chosenItem: .constant([FreeWeights.mock])
    )
    
    return RouterView { router in
        builder.equipmentPickerView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
