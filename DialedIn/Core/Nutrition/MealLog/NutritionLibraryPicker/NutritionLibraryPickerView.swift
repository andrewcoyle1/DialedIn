//
//  NutritionLibraryPickerView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

struct NutritionLibraryPickerDelegate {
    var items: Binding<[MealItemModel]>
    var onPick: (MealItemModel) -> Void
}

struct NutritionLibraryPickerView<FoodItemSearch: View, BarcodeScanner: View, FoodPhotoScanner: View>: View {

    @State var presenter: NutritionLibraryPickerPresenter

    var delegate: NutritionLibraryPickerDelegate

    @ViewBuilder var barcodeScanner: (BarcodeScannerDelegate) -> BarcodeScanner
    @ViewBuilder var foodItemSearch: (FoodItemSearchDelegate) -> FoodItemSearch
    @ViewBuilder var foodPhotoScanner: (FoodPhotoScannerDelegate) -> FoodPhotoScanner

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(NutritionPickerMode.allCases) { mode in
                        Button {
                            presenter.onModePressed(mode)
                        } label: {
                            Label(mode.title, systemImage: mode.systemName).tag(mode)
                        }
                        .buttonStyle(.glass)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal)
            
            switch presenter.mode {
            case .barcode:
                barcodeScanner(BarcodeScannerDelegate())
            case .search:
                foodItemSearch(FoodItemSearchDelegate())
            case .ai:
                foodPhotoScanner(FoodPhotoScannerDelegate(onPick: delegate.onPick))
            case .quickAdd:
                List {
                    quickAddSection
                }
            case .library:
                List {
                    librarySection
                }
            case .describe:
                List {
                    describeSection
                }
            }
            
        }
        .navigationTitle("Add Item")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var quickAddSection: some View {
        Text("Quick Add Section...")
    }

    private var librarySection: some View {
        Text("Library Section...")
    }

    private var describeSection: some View {
        Text("Describe Section...")
    }
        
    private var ingredientsSection: some View {
        Section {
            if presenter.ingredientTemplates.isEmpty {
                Text(presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No ingredients to show yet" : "No results")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(presenter.ingredientTemplates) { ingredient in
                    Button {
                        presenter.navToIngredientAmount(ingredient, onPick: delegate.onPick)
                    } label: {
                        CustomListCellView(
                            imageName: ingredient.imageURL,
                            title: ingredient.name,
                            subtitle: ingredient.description
                        )
                    }
                }
                .removeListRowFormatting()
            }
        }
        
    }
    
    private var recipesSection: some View {
        Section {
            if presenter.recipes.isEmpty {
                Text(presenter.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "No recipes to show yet" : "No results")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(presenter.recipes) { recipe in
                    Button {
                        presenter.navToRecipeAmount(recipe, onPick: delegate.onPick)
                    } label: {
                        CustomListCellView(
                            imageName: nil,
                            title: recipe.name,
                            subtitle: recipe.description
                        )
                    }
                }
                .removeListRowFormatting()
            }
        }
    }
}

extension CoreBuilder {
    func nutritionLibraryPickerView(router: AnyRouter, delegate: NutritionLibraryPickerDelegate) -> some View {
        NutritionLibraryPickerView(
            presenter: NutritionLibraryPickerPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self)),
            delegate: delegate,
            barcodeScanner: { scannerDelegate in
                self.barcodeScannerView(router: router, delegate: scannerDelegate)
            },
            foodItemSearch: { searchDelegate in
                self.foodItemSearchView(router: router, delegate: searchDelegate)
            },
            foodPhotoScanner: { photoDelegate in
                self.foodPhotoScannerView(router: router, delegate: photoDelegate)
            }
        )
    }
}

extension CoreRouter {
    func showNutritionLibraryPickerView(delegate: NutritionLibraryPickerDelegate) {
        router.showScreen(.sheetConfig(config: ResizableSheetConfig(detents: [.fraction(0.95)], dragIndicator: .visible))) { router in
            builder.nutritionLibraryPickerView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    @Previewable @State var items: [MealItemModel] = MealItemModel.mocks
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = NutritionLibraryPickerDelegate(
        items: $items,
        onPick: { item in
            print(item.displayName)
        }
    )
    RouterView { router in
        builder.nutritionLibraryPickerView(router: router, delegate: delegate)
    }
    
}
