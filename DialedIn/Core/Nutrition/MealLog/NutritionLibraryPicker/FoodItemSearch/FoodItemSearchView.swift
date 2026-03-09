import SwiftUI

struct FoodItemSearchDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct FoodItemSearchView: View {
    
    @State var presenter: FoodItemSearchPresenter
    let delegate: FoodItemSearchDelegate
    
    var body: some View {
        List {
            fromHistorySection
            fromCommonSection
            fromBrandedSection
            fromOpenFoodFactsSection
        }
        .searchable(text: $presenter.searchText)
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
    
    private var fromHistorySection: some View {
        listSectionBuilder(
            header: "From History",
            items: presenter.fromHistoryFoodItems
        )
    }
    
    private var fromCommonSection: some View {
        listSectionBuilder(
            header: "Common",
            items: presenter.fromCommonFoodItems
        )
    }
    
    private var fromBrandedSection: some View {
        listSectionBuilder(
            header: "Branded",
            items: presenter.fromBrandedFoodItems
        )
    }
    
    private var fromOpenFoodFactsSection: some View {
        listSectionBuilder(
            header: "Open Food Facts",
            items: presenter.fromOpenFoodFactsFoodItems
        )
    }
    
    @ViewBuilder
    private func listSectionBuilder(header: String, items: [MealLogModel]) -> some View {
        Section {
            ForEach(items) { foodItem in
                foodItemCard(item: foodItem)
            }
            .removeListRowFormatting()
        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text(header)
                Spacer()
                Text("See 15 more")
                    .font(.subheadline)
                    .underline()
            }
        }
    }
    
    @ViewBuilder
    private func foodItemCard(item: MealLogModel) -> some View {
        CustomListCellView(
            imageName: Constants.randomImage,
            title: "Original Salted Potato Rings by Hula Hoops",
            subtitle: "120 kcal 1P 6F 17C - 1 pack (24 g)"
        )
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = FoodItemSearchDelegate()
    
    return RouterView { router in
        builder.foodItemSearchView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func foodItemSearchView(router: AnyRouter, delegate: FoodItemSearchDelegate) -> some View {
        FoodItemSearchView(
            presenter: FoodItemSearchPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showFoodItemSearchView(delegate: FoodItemSearchDelegate) {
        router.showScreen(.push) { router in
            builder.foodItemSearchView(router: router, delegate: delegate)
        }
    }
    
}
