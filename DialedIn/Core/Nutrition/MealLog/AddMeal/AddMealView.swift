//
//  AddMeal.swift
//  DialedIn
//
//  Created by Andrew Coyle on 13/10/2025.
//

import SwiftUI

struct AddMealDelegate {
    let mealLog: MealLogModel
}

struct AddMealView: View {

    @State var presenter: AddMealPresenter

    let delegate: AddMealDelegate

    var body: some View {
        List {
            yourPlateSection
            nutritionSection
            if presenter.showAllNutrients {
                carbBreakdownSection
                fatBreakdownSection
                proteinBreakdownSection
                vitaminBreakdownSection
                mineralBreakdownSection
                otherBreakdownSection
            }
            CustomToggleView(symbolName: "carrot", title: "Show all nutrients", subtitle: nil, bool: $presenter.showAllNutrients)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button {
                    presenter.saveMeal()
                } label: {
                    Text("Log Foods")
                        .padding(8)
                        .padding(.horizontal, 8)
                }
                .buttonStyle(.glassProminent)
                .disabled(presenter.mealLog.items.isEmpty)
            }
            .padding(.horizontal)
        }
    }

    private var yourPlateSection: some View {
        Section {
            if presenter.mealLog.items.isEmpty {
                CustomLabelButtonView(symbolName: "info", title: "Your plate is empty", subtitle: "Add foods using Search, Scan or AI.") {
                    Button {
                        presenter.onShowPickerPressed()
                    } label: {
                        Text("Add")
                            .padding(.horizontal, 8)
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                ForEach(presenter.mealLog.items) { mealItem in
                    CustomListCellView(title: mealItem.displayName)
                        .removeListRowFormatting()
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                guard let index = presenter.mealLog.items.firstIndex(of: mealItem) else { return }
                                presenter.mealLog.items.remove(at: index)
                            }
                        }
                }
            }
        } header: {
            Text("Your Plate")
        }
    }
    
    private var nutritionSection: some View {
        Section {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100)), count: 2)) {
                AnalyticsCard(
                    title: "Calories",
                    subtitle: "791 kcal in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .blue)
                    }
                AnalyticsCard(
                    title: "Protein",
                    subtitle: "65.1 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .proteinColor)
                    }
                AnalyticsCard(
                    title: "Fat",
                    subtitle: "38.4 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .fatColor)
                    }
                AnalyticsCard(
                    title: "Carbs",
                    subtitle: "23.4 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .carbsColor)
                    }
            }
            .removeListRowFormatting()
        } header: {
            HStack {
                Text("Nutrition")
                Spacer()
                Picker("", selection: $presenter.nutritionScope) {
                    ForEach(NutritionScope.allCases) { scope in
                        Text(scope.rawValue.capitalized)
                            .tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 160)
            }
        }
    }
        
    private var carbBreakdownSection: some View {
        Section {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100)), count: 2)) {
                AnalyticsCard(
                    title: "Calories",
                    subtitle: "791 kcal in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .blue)
                    }
                AnalyticsCard(
                    title: "Protein",
                    subtitle: "65.1 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .proteinColor)
                    }
                AnalyticsCard(
                    title: "Fat",
                    subtitle: "38.4 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .fatColor)
                    }
                AnalyticsCard(
                    title: "Carbs",
                    subtitle: "23.4 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .carbsColor)
                    }
            }
            .removeListRowFormatting()
        } header: {
            Text("Carb Breakdown")
        }
    }
    
    private var fatBreakdownSection: some View {
        Section {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100)), count: 2)) {
                AnalyticsCard(
                    title: "Calories",
                    subtitle: "791 kcal in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .blue)
                    }
                AnalyticsCard(
                    title: "Protein",
                    subtitle: "65.1 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .proteinColor)
                    }
                AnalyticsCard(
                    title: "Fat",
                    subtitle: "38.4 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .fatColor)
                    }
                AnalyticsCard(
                    title: "Carbs",
                    subtitle: "23.4 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .carbsColor)
                    }
            }
            .removeListRowFormatting()
        } header: {
            Text("Carb Breakdown")
        }
    }
    
    private var proteinBreakdownSection: some View {
        Section {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100)), count: 2)) {
                AnalyticsCard(
                    title: "Calories",
                    subtitle: "791 kcal in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .blue)
                    }
                AnalyticsCard(
                    title: "Protein",
                    subtitle: "65.1 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .proteinColor)
                    }
                AnalyticsCard(
                    title: "Fat",
                    subtitle: "38.4 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .fatColor)
                    }
                AnalyticsCard(
                    title: "Carbs",
                    subtitle: "23.4 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .carbsColor)
                    }
            }
            .removeListRowFormatting()
        } header: {
            Text("Carb Breakdown")
        }
    }
    
    private var vitaminBreakdownSection: some View {
        Section {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100)), count: 2)) {
                AnalyticsCard(
                    title: "Calories",
                    subtitle: "791 kcal in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .blue)
                    }
                AnalyticsCard(
                    title: "Protein",
                    subtitle: "65.1 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .proteinColor)
                    }
                AnalyticsCard(
                    title: "Fat",
                    subtitle: "38.4 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .fatColor)
                    }
                AnalyticsCard(
                    title: "Carbs",
                    subtitle: "23.4 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .carbsColor)
                    }
            }
            .removeListRowFormatting()
        } header: {
            Text("Carb Breakdown")
        }
    }
    
    private var mineralBreakdownSection: some View {
        Section {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100)), count: 2)) {
                AnalyticsCard(
                    title: "Calories",
                    subtitle: "791 kcal in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .blue)
                    }
                AnalyticsCard(
                    title: "Protein",
                    subtitle: "65.1 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .proteinColor)
                    }
                AnalyticsCard(
                    title: "Fat",
                    subtitle: "38.4 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .fatColor)
                    }
                AnalyticsCard(
                    title: "Carbs",
                    subtitle: "23.4 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .carbsColor)
                    }
            }
            .removeListRowFormatting()
        } header: {
            Text("Carb Breakdown")
        }
    }
    
    private var otherBreakdownSection: some View {
        Section {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100)), count: 2)) {
                AnalyticsCard(
                    title: "Calories",
                    subtitle: "791 kcal in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .blue)
                    }
                AnalyticsCard(
                    title: "Protein",
                    subtitle: "65.1 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .proteinColor)
                    }
                AnalyticsCard(
                    title: "Fat",
                    subtitle: "38.4 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .fatColor)
                    }
                AnalyticsCard(
                    title: "Carbs",
                    subtitle: "23.4 g in plate",
                    subsubtitle: "",
                    subsubsubtitle: "") {
                        MacroProgressChart(current: 0.5, maxValue: 1, color: .carbsColor)
                    }
            }
            .removeListRowFormatting()
        } header: {
            Text("Carb Breakdown")
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.dismissScreen()
            } label: {
                Image(systemName: "xmark")
            }
        }

        ToolbarSpacer(.flexible, placement: .topBarLeading)
        ToolbarItem(placement: .topBarLeading) {
            Button {
                
            } label: {
                VStack {
                    Text(delegate.mealLog.date.formatted(date: .omitted, time: .shortened))
                        .font(.subheadline)
                    Text(delegate.mealLog.date.formatted(date: .numeric, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        ToolbarSpacer(.flexible, placement: .topBarLeading)

        ToolbarItem(placement: .topBarLeading) {
            Button {
                
            } label: {
                Text("0/1985")
                    .font(.subheadline)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            HStack {
                cartView
                Button {
                    presenter.onShowPickerPressed()
                } label: {
                    Image(systemName: "chevron.up")

                }
            }
            .frame(maxWidth: .infinity)

        }
    }
    
    private var cartView: some View {
        HStack {
            Image(systemName: "fork.knife")
            mealItemImagesSection
            Spacer()
        }
        .padding(.leading, 8)
    }
    
    private var mealItemImagesSection: some View {
        HStack(spacing: -10) {
            ForEach(presenter.mealLog.items.prefix(5)) { mealItem in
                mealItemCircle(mealItem: mealItem)
            }
        }
    }

    @ViewBuilder
    private func mealItemCircle(mealItem: MealItemModel) -> some View {
        ZStack {
            Circle()
                .fill(Color(uiColor: .secondarySystemBackground))

            ImageLoaderView(
                urlString: "SplashScreen",
                resizingMode: .fit,
                clipShape: AnyShape(Circle())
            )
        }
        .frame(width: 38, height: 38)
        .overlay(Circle().stroke(Color(uiColor: .systemBackground), lineWidth: 2))
    }

}

extension CoreBuilder {
    func addMealView(router: AnyRouter, delegate: AddMealDelegate) -> some View {
        AddMealView(
            presenter: AddMealPresenter(
                interactor: interactor,
                router: CoreRouter(
                    router: router,
                    builder: self
                ),
                delegate: delegate
            ),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showAddMealView(delegate: AddMealDelegate) {
        router.showScreen(.fullScreenCover) { router in
            builder.addMealView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = AddMealDelegate(mealLog: MealLogModel.mock)
    RouterView { router in
        builder.addMealView(router: router, delegate: delegate)
    }
    
}
