import SwiftUI

struct EquipmentPickerDelegate {
    let items: [AnyEquipment]
    let headerTitle: String
    var chosenItem: Binding<[EquipmentRef]>
    
    init(
        items: [AnyEquipment],
        headerTitle: String = "Equipment",
        chosenItem: Binding<[EquipmentRef]>
    ) {
        self.items = items
        self.headerTitle = headerTitle
        self.chosenItem = chosenItem
    }
}

struct EquipmentPickerView: View {
    
    @State var presenter: EquipmentPickerPresenter
    let delegate: EquipmentPickerDelegate
    @Binding private var chosenItems: [EquipmentRef]
    
    init(presenter: EquipmentPickerPresenter, delegate: EquipmentPickerDelegate) {
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
    private func rowItem(item: AnyEquipment) -> some View {
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
                .stroke(lineWidth: chosenItems.contains(item.ref) ? 12 : 3)
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
    
    func equipmentPickerView(router: Router, delegate: EquipmentPickerDelegate) -> some View {
        EquipmentPickerView(
            presenter: EquipmentPickerPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showEquipmentPickerView(delegate: EquipmentPickerDelegate) {
        router.showScreen(.sheet) { router in
            builder.equipmentPickerView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = EquipmentPickerDelegate(
        items: GymProfileModel.mock.freeWeights.map(AnyEquipment.init),
        headerTitle: "Free Weights",
        chosenItem: .constant([FreeWeights.mock.equipmentRef])
    )
    
    return RouterView { router in
        builder.equipmentPickerView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
