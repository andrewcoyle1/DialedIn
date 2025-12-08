//
//  CreateIngredientView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI
import PhotosUI
import SwiftfulRouting

struct CreateIngredientView: View {

    @State var presenter: CreateIngredientPresenter

    var body: some View {
        List {
            imageSection
            nameSection
            macroNutrientSection
            essentialMacroMineralsSection
            essentialTraceMineralsSection
            fatSolubleMineralsSection
            waterSolubleVitaminsSection
            bioactiveCompounts
        }
        .navigationBarTitle("New Custom Ingredient")
        .navigationSubtitle("Define ingredient details and nutrition")
        .navigationBarTitleDisplayMode(.large)
        .scrollIndicators(.hidden)
        .screenAppearAnalytics(name: "CreateIngredientView")
        .toolbar {
            toolbarContent
        }
        .onChange(of: presenter.selectedPhotoItem) {
            guard let newItem = presenter.selectedPhotoItem else { return }

            Task {
                await presenter.onImageSelectorChanged(newItem)
            }
        }
    }

    private var imageSection: some View {
        Section {
            HStack {
                Spacer()
                Button {
                    presenter.onImageSelectorPressed()
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.001))
                        Group {
                            if let data = presenter.selectedImageData {
                                #if canImport(UIKit)
                                if let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                }
                                #elseif canImport(AppKit)
                                if let nsImage = NSImage(data: data) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .scaledToFill()
                                }
                                #endif
                            } else {
                                #if canImport(UIKit)
                                if let generatedImage = presenter.generatedImage {
                                    Image(uiImage: generatedImage)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(systemName: "carrot.fill")
                                        .font(.system(size: 120))
                                        .foregroundStyle(.accent)
                                }
                                #else
                                Image(systemName: "carrot.fill")
                                    .font(.system(size: 120))
                                    .foregroundStyle(.accent)
                                #endif
                            }
                        }
                    }
                    .frame(width: 120, height: 120)
                }
                .photosPicker(isPresented: $presenter.isImagePickerPresented, selection: $presenter.selectedPhotoItem, matching: .images)
                Spacer()
            }
        } header: {
            HStack {
                Text("Ingredient Image")
                Spacer()
                Button {
                    presenter.onGenerateImagePressed()
                } label: {
                    Image(systemName: "wand.and.sparkles")
                        .font(.system(size: 20))
                }
                .disabled(presenter.isGenerating || (presenter.name?.isEmpty ?? true))
            }
        }
        .removeListRowFormatting()
    }
    
    private var nameSection: some View {
        Section {
            TextField("Add name", text: Binding(
                get: { presenter.name ?? "" },
                set: { newValue in
                    presenter.name = newValue.isEmpty ? nil : newValue
                }
            ))
            TextField("Add description", text: Binding(
                get: { presenter.description ?? "" },
                set: { newValue in
                    presenter.description = newValue.isEmpty ? nil : newValue
                }
            ))
        } header: {
            Text("Name")
        }
    }
    
    private var macroNutrientSection: some View {
        Section {
            inputRow(label: "Calories", value: $presenter.calories, unit: "kcal")
            inputRow(label: "Protein", value: $presenter.protein, unit: "g")
            inputRow(label: "Carbs", value: $presenter.carbs, unit: "g")
            inputRow(label: "Total Fat", value: $presenter.fatTotal, unit: "g")
            inputRow(label: "Saturated Fat", value: $presenter.fatSaturated, unit: "g")
            inputRow(label: "Monounsaturated Fat", value: $presenter.fatMonounsaturated, unit: "g")
            inputRow(label: "Polyunsaturated Fat", value: $presenter.fatPolyunsaturated, unit: "g")
            inputRow(label: "Fiber", value: $presenter.fiber, unit: "g")
            inputRow(label: "Sugar", value: $presenter.sugar, unit: "g")
        } header: {
            Text("Macronutrients")
        }
    }

    private var essentialMacroMineralsSection: some View {
        Section {
            // Essential Macrominerals - Required in larger amounts
            inputRow(label: "Calcium", value: $presenter.calciumMg, unit: "mg")
            inputRow(label: "Phosphorus", value: $presenter.phosphorusMg, unit: "mg")
            inputRow(label: "Magnesium", value: $presenter.magnesiumMg, unit: "mg")
            inputRow(label: "Sodium", value: $presenter.sodiumMg, unit: "mg")
            inputRow(label: "Potassium", value: $presenter.potassiumMg, unit: "mg")
            inputRow(label: "Chloride", value: $presenter.chlorideMg, unit: "mg")
        } header: {
            Text("Essential Macrominerals")
        }
    }

    private var essentialTraceMineralsSection: some View {
        Section {
            // Essential Trace Minerals - Required in smaller amounts
            inputRow(label: "Iron", value: $presenter.ironMg, unit: "mg")
            inputRow(label: "Zinc", value: $presenter.zincMg, unit: "mg")
            inputRow(label: "Copper", value: $presenter.copperMg, unit: "mg")
            inputRow(label: "Manganese", value: $presenter.manganeseMg, unit: "mg")
            inputRow(label: "Iodine", value: $presenter.iodineMcg, unit: "μg")
            inputRow(label: "Selenium", value: $presenter.seleniumMcg, unit: "μg")
            inputRow(label: "Molybdenum", value: $presenter.molybdenumMcg, unit: "μg")
            inputRow(label: "Chromium", value: $presenter.chromiumMcg, unit: "μg")
        } header: {
            Text("Essential Trace Minerals")
        }
    }

    private var fatSolubleMineralsSection: some View {
        Section {
            // Fat-Soluble Vitamins - A, D, E, K
            inputRow(label: "Vitamin A", value: $presenter.vitaminAMcg, unit: "μg RAE")
            inputRow(label: "Vitamin D", value: $presenter.vitaminDMcg, unit: "μg")
            inputRow(label: "Vitamin E", value: $presenter.vitaminEMg, unit: "mg α-tocopherol")
            inputRow(label: "Vitamin K", value: $presenter.vitaminKMcg, unit: "μg")
        } header: {
            Text("Fat-Soluble Vitamins")
        }
    }

    private var waterSolubleVitaminsSection: some View {
        Section {
            // Water-Soluble Vitamins - B-Complex & C
            inputRow(label: "Thiamin - B1", value: $presenter.thiaminMg, unit: "mg")
            inputRow(label: "Riboflavin - B2", value: $presenter.riboflavinMg, unit: "mg")
            inputRow(label: "Niacin - B3", value: $presenter.niacinMg, unit: "mg NE")
            inputRow(label: "Pantothenic Acid - B5", value: $presenter.pantothenicAcidMg, unit: "mg")
            inputRow(label: "Vitamin B6", value: $presenter.vitaminB6Mg, unit: "mg")
            inputRow(label: "Biotin - B7", value: $presenter.biotinMcg, unit: "μg")
            inputRow(label: "Folate - B9", value: $presenter.folateMcg, unit: "μg DFE")
            inputRow(label: "Vitamin B12", value: $presenter.vitaminB12Mcg, unit: "μg")
            inputRow(label: "Vitamin C", value: $presenter.vitaminCMg, unit: "mg")
        } header: {
            Text("Water-Soluble Vitamins")
        }
    }
    private var bioactiveCompounts: some View {
        Section {
            // Bioactive Compounds
            inputRow(label: "Cholesterol", value: $presenter.cholesterolMg, unit: "mg")
            inputRow(label: "Caffeine", value: $presenter.caffeineMg, unit: "mg")
        } header: {
            Text("Bioactive Compounds")
        }
    }

    private func inputRow(label: String, value: Binding<Double?>, unit: String? = nil) -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            Text(label)
            Spacer()
            TextField("0", value: value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 80)
            Text(" " + (unit ?? ""))
                .foregroundStyle(value.wrappedValue != nil ? .primary : .secondary)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onCancelPressed()
            } label: {
                Image(systemName: "xmark")
            }
        }
        #if DEBUG || MOCK
        ToolbarSpacer(.fixed, placement: .topBarLeading)
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                Task {
                    await presenter.onSavePressed()
                }
            } label: {
                Image(systemName: "checkmark")
            }
            .buttonStyle(.glassProminent)
            .disabled(!presenter.canSave || presenter.isSaving)
        }
    }
}

extension CoreBuilder {
    func createIngredientView(router: AnyRouter) -> some View {
        CreateIngredientView(
            presenter: CreateIngredientPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showCreateIngredientView() {
        router.showScreen(.sheet) { router in
            builder.createIngredientView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.createIngredientView(router: router)
    }
    .previewEnvironment()
}
