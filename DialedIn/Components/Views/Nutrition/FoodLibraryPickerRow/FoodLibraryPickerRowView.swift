import SwiftUI

protocol FoodItem {
    
    var imageURL: String? { get }
    var name: String { get }
    var calories: Double? { get }
    var carbs: Double? { get }
    var protein: Double? { get }
    var fats: Double? { get }
    var portionQuantityCalculated: Double? { get }
    var portionNameCalculated: String? { get }
}

struct FoodLibraryPickerRowDelegate<T: FoodItem> {
    
    let item: T
    let onAdd: (() -> Void)?
    let onQuickAdd: (() -> Void)?
    
    init(
        item: T,
        onAdd: (() -> Void)? = nil,
        onQuickAdd: (() -> Void)? = nil
    ) {
        self.item = item
        self.onAdd = onAdd
        self.onQuickAdd = onQuickAdd
    }
    
    var eventParameters: [String: Any]? {
        nil
    }
}

struct FoodLibraryPickerRowView<T: FoodItem>: View {
    
    let delegate: FoodLibraryPickerRowDelegate<T>
    
    var body: some View {
        HStack {
            Button {
                delegate.onAdd?()
            } label: {
                HStack {
                    ImageLoaderView(urlString: delegate.item.imageURL ?? Constants.randomImage)
                        .cornerRadius(10)
                        .frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        Text(delegate.item.name)
                            .font(.subheadline)
                        HStack {
                            Text("\(String(format: "%g", delegate.item.calories ?? 0)) kcal")
                            Text("\(String(format: "%g", delegate.item.protein ?? 0)) P")
                            Text("\(String(format: "%g", delegate.item.fats ?? 0)) F")
                            Text("\(String(format: "%g", delegate.item.carbs ?? 0)) C")
                            Divider()
                            if let quantity = delegate.item.portionQuantityCalculated, let name = delegate.item.portionNameCalculated {
                                Text("\(String(format: "%g", quantity)) \(name)")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
                .tappableBackground()
            }
            .buttonStyle(.plain)
            Spacer()
            Button {
                delegate.onQuickAdd?()
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.circle)
        }
    }
}

#Preview {    
    List {
        ForEach(FoodModel.mocks) { food in
            let delegate = FoodLibraryPickerRowDelegate<FoodModel>(
                item: food,
                onAdd: { print("On Add") },
                onQuickAdd: { print("On Quick Add") }
            )

            return FoodLibraryPickerRowView(delegate: delegate)
        }
    }
}
