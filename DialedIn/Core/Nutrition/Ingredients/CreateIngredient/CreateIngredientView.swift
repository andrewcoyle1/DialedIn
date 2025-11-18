//
//  CreateIngredientView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 27/09/2025.
//

import SwiftUI
import PhotosUI

struct CreateIngredientView: View {
    @Environment(\.dismiss) private var dismiss

    @State var viewModel: CreateIngredientViewModel

    @ViewBuilder var devSettingsView: () -> AnyView

    var body: some View {
        NavigationStack {
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
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.onCancelPressed(onDismiss: {
                            dismiss()
                        })
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                #if DEBUG || MOCK
                ToolbarSpacer(.fixed, placement: .topBarLeading)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.showDebugView = true
                    } label: {
                        Image(systemName: "info")
                    }
                }
                #endif
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.onSavePressed(onDismiss: {
                                dismiss()
                            })
                        }
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(!viewModel.canSave || viewModel.isSaving)
                }
            }
            .onChange(of: viewModel.selectedPhotoItem) {
                guard let newItem = viewModel.selectedPhotoItem else { return }
                
                Task {
                    await viewModel.onImageSelectorChanged(newItem)
                }
            }
            #if DEBUG || MOCK
            .sheet(isPresented: $viewModel.showDebugView) {
                devSettingsView()
            }
            #endif
            .showCustomAlert(alert: $viewModel.alert)
        }
        
    }

    private var imageSection: some View {
        Section {
            HStack {
                Spacer()
                Button {
                    viewModel.onImageSelectorPressed()
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.001))
                        Group {
                            if let data = viewModel.selectedImageData {
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
                                if let generatedImage = viewModel.generatedImage {
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
                .photosPicker(isPresented: $viewModel.isImagePickerPresented, selection: $viewModel.selectedPhotoItem, matching: .images)
                Spacer()
            }
        } header: {
            HStack {
                Text("Ingredient Image")
                Spacer()
                Button {
                    viewModel.onGenerateImagePressed()
                } label: {
                    Image(systemName: "wand.and.sparkles")
                        .font(.system(size: 20))
                }
                .disabled(viewModel.isGenerating || (viewModel.name?.isEmpty ?? true))
            }
        }
        .removeListRowFormatting()
    }
    
    private var nameSection: some View {
        Section {
            TextField("Add name", text: Binding(
                get: { viewModel.name ?? "" },
                set: { newValue in
                    viewModel.name = newValue.isEmpty ? nil : newValue
                }
            ))
            TextField("Add description", text: Binding(
                get: { viewModel.description ?? "" },
                set: { newValue in
                    viewModel.description = newValue.isEmpty ? nil : newValue
                }
            ))
        } header: {
            Text("Name")
        }
    }
    
    private var macroNutrientSection: some View {
        Section {
            inputRow(label: "Calories", value: $viewModel.calories, unit: "kcal")
            inputRow(label: "Protein", value: $viewModel.protein, unit: "g")
            inputRow(label: "Carbs", value: $viewModel.carbs, unit: "g")
            inputRow(label: "Total Fat", value: $viewModel.fatTotal, unit: "g")
            inputRow(label: "Saturated Fat", value: $viewModel.fatSaturated, unit: "g")
            inputRow(label: "Monounsaturated Fat", value: $viewModel.fatMonounsaturated, unit: "g")
            inputRow(label: "Polyunsaturated Fat", value: $viewModel.fatPolyunsaturated, unit: "g")
            inputRow(label: "Fiber", value: $viewModel.fiber, unit: "g")
            inputRow(label: "Sugar", value: $viewModel.sugar, unit: "g")
        } header: {
            Text("Macronutrients")
        }
    }

    private var essentialMacroMineralsSection: some View {
        Section {
            // Essential Macrominerals - Required in larger amounts
            inputRow(label: "Calcium", value: $viewModel.calciumMg, unit: "mg")
            inputRow(label: "Phosphorus", value: $viewModel.phosphorusMg, unit: "mg")
            inputRow(label: "Magnesium", value: $viewModel.magnesiumMg, unit: "mg")
            inputRow(label: "Sodium", value: $viewModel.sodiumMg, unit: "mg")
            inputRow(label: "Potassium", value: $viewModel.potassiumMg, unit: "mg")
            inputRow(label: "Chloride", value: $viewModel.chlorideMg, unit: "mg")
        } header: {
            Text("Essential Macrominerals")
        }
    }

    private var essentialTraceMineralsSection: some View {
        Section {
            // Essential Trace Minerals - Required in smaller amounts
            inputRow(label: "Iron", value: $viewModel.ironMg, unit: "mg")
            inputRow(label: "Zinc", value: $viewModel.zincMg, unit: "mg")
            inputRow(label: "Copper", value: $viewModel.copperMg, unit: "mg")
            inputRow(label: "Manganese", value: $viewModel.manganeseMg, unit: "mg")
            inputRow(label: "Iodine", value: $viewModel.iodineMcg, unit: "μg")
            inputRow(label: "Selenium", value: $viewModel.seleniumMcg, unit: "μg")
            inputRow(label: "Molybdenum", value: $viewModel.molybdenumMcg, unit: "μg")
            inputRow(label: "Chromium", value: $viewModel.chromiumMcg, unit: "μg")
        } header: {
            Text("Essential Trace Minerals")
        }
    }

    private var fatSolubleMineralsSection: some View {
        Section {
            // Fat-Soluble Vitamins - A, D, E, K
            inputRow(label: "Vitamin A", value: $viewModel.vitaminAMcg, unit: "μg RAE")
            inputRow(label: "Vitamin D", value: $viewModel.vitaminDMcg, unit: "μg")
            inputRow(label: "Vitamin E", value: $viewModel.vitaminEMg, unit: "mg α-tocopherol")
            inputRow(label: "Vitamin K", value: $viewModel.vitaminKMcg, unit: "μg")
        } header: {
            Text("Fat-Soluble Vitamins")
        }
    }

    private var waterSolubleVitaminsSection: some View {
        Section {
            // Water-Soluble Vitamins - B-Complex & C
            inputRow(label: "Thiamin - B1", value: $viewModel.thiaminMg, unit: "mg")
            inputRow(label: "Riboflavin - B2", value: $viewModel.riboflavinMg, unit: "mg")
            inputRow(label: "Niacin - B3", value: $viewModel.niacinMg, unit: "mg NE")
            inputRow(label: "Pantothenic Acid - B5", value: $viewModel.pantothenicAcidMg, unit: "mg")
            inputRow(label: "Vitamin B6", value: $viewModel.vitaminB6Mg, unit: "mg")
            inputRow(label: "Biotin - B7", value: $viewModel.biotinMcg, unit: "μg")
            inputRow(label: "Folate - B9", value: $viewModel.folateMcg, unit: "μg DFE")
            inputRow(label: "Vitamin B12", value: $viewModel.vitaminB12Mcg, unit: "μg")
            inputRow(label: "Vitamin C", value: $viewModel.vitaminCMg, unit: "mg")
        } header: {
            Text("Water-Soluble Vitamins")
        }
    }
    private var bioactiveCompounts: some View {
        Section {
            // Bioactive Compounds
            inputRow(label: "Cholesterol", value: $viewModel.cholesterolMg, unit: "mg")
            inputRow(label: "Caffeine", value: $viewModel.caffeineMg, unit: "mg")
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
}

#Preview("As sheet") {
    @Previewable @State var isPresented: Bool = true
    let builder = CoreBuilder(container: DevPreview.shared.container)
    Button {
        isPresented = true
    } label: {
        Text("Present")
    }
    .sheet(isPresented: $isPresented) {
        builder.createIngredientView()
    }
    .previewEnvironment()
}

#Preview("Is saving") {
    @Previewable @State var isPresented: Bool = true
    let builder = CoreBuilder(container: DevPreview.shared.container)
    Button {
        isPresented = true
    } label: {
        Text("Present")
    }
    .sheet(isPresented: $isPresented) {
        builder.createIngredientView()
    }
    .previewEnvironment()
}

#Preview("As fullscreen cover") {
    @Previewable @State var isPresented: Bool = true
    let builder = CoreBuilder(container: DevPreview.shared.container)

    Button {
        isPresented = true
    } label: {
        Text("Present")
    }
    .fullScreenCover(isPresented: $isPresented) {
        builder.createIngredientView()
    }
    .previewEnvironment()
    
}
