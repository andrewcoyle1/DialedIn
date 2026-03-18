import SwiftUI

struct FoodLogSettingsDelegate {

}

struct FoodLogSettingsView: View {

    @State var presenter: FoodLogSettingsPresenter
    let delegate: FoodLogSettingsDelegate

    var body: some View {
        List {
            Section {
                CustomToggleView(
                    title: "Show Overages",
                    subtitle: presenter.showOverages ? "No negative numbers will be used if you exceed a nutrient target." : "Negative numbers will be used in nutrient remaining views if you exceed your target.",
                    bool: $presenter.showOverages
                )
            } header: {
                Text("Nutrient Reporting")
            }

            Section {
                CustomLabelButtonView(
                    symbolName: "clock",
                    title: "Hour Range",
                    subtitle: presenter.hourRangeSubtitle) {
                        Text("Edit")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {
                                presenter.onEditHourRangePressed()
                            }
                    }
                CustomLabelButtonView(
                    symbolName: "chart.bar.yaxis",
                    title: "Alignment",
                    subtitle: presenter.alignmentSubtitle) {
                        Text("Edit")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {
                                presenter.onEditAlignmentPressed()
                            }
                    }
                CustomToggleView(
                    symbolName: "plus.circle",
                    title: "Add Foods to Hour",
                    subtitle: "Show + button on each hour",
                    bool: $presenter.showAddFoodsButton
                )
                CustomToggleView(
                    symbolName: "clock",
                    title: "Food Timestamps",
                    subtitle: "Show timestamps",
                    bool: $presenter.showsFoodTimestamps
                )
                CustomToggleView(
                    symbolName: "clock",
                    title: "Hourly Macro Totals",
                    subtitle: "Show",
                    bool: $presenter.showHourlyMacroTotals
                )
                CustomToggleView(
                    symbolName: "clock",
                    title: "Calendar Week Banner",
                    subtitle: "Show",
                    bool: $presenter.showCalendarWeekBanner
                )
                CustomToggleView(
                    symbolName: "clock",
                    title: "Premove",
                    subtitle: "Pre-log meals before eating",
                    bool: $presenter.premove
                )
            } header: {
                Text("Timeline Options")
            }

            Section {
                CustomToggleView(
                    title: "Branded Results",
                    subtitle: presenter.showBrandedFoods ? "On" : "Off",
                    bool: $presenter.showBrandedFoods
                )
                CustomToggleView(
                    title: "Open Food Facts Results",
                    subtitle: presenter.showOpenFoodFactsFoods ? "On" : "Off",
                    bool: $presenter.showOpenFoodFactsFoods
                )
            } header: {
                Text("Food Search")
            }

            Section {
                CustomLabelButtonView(
                    title: "Timeline Food Tiles",
                    subtitle: "Customise how foods appear in your timeline") {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .padding()
                            .anyButton(.press) {
                                presenter.onTimelineFoodTilesPressed()
                            }

                    }
                CustomLabelButtonView(
                    title: "Logger Food Tiles",
                    subtitle: "Customise how foods appear in search") {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .padding()
                            .anyButton(.press) {
                                presenter.onLoggerFoodTilesPressed()
                            }

                    }
            } header: {
                Text("Food Tiles")
            }

            Section {
                CustomLabelButtonView(
                    title: "Logger Banner",
                    subtitle: "Customise the top of your plate") {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .padding()
                            .anyButton(.press) {
                                presenter.onLoggedBannerPressed()
                            }

                    }
                CustomLabelButtonView(
                    title: "Time Selection",
                    subtitle: "Customise how you change time while logging") {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .padding()
                            .anyButton(.press) {
                                presenter.onTimeSelectionPressed()
                            }

                    }
                CustomLabelButtonView(
                    title: "Favourite Measurements",
                    subtitle: "Select the measurements to pin to serving size selections.") {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .padding()
                            .anyButton(.press) {
                                presenter.onFavouriteMeasurementsPressed()
                            }

                    }
                CustomLabelButtonView(
                    title: "Optimisation",
                    subtitle: "Optimise for speed") {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                            .padding()
                            .anyButton(.press) {
                                presenter.onOptimisationPressed()
                            }
                    }

            } header: {
                Text("Logger Options")
            }
        }
        .navigationTitle("Food Log")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            presenter.onViewAppear()
        }
        .onDisappear {
            presenter.onViewDisappear()
        }
        .sheet(isPresented: $presenter.isShowingHourRangePicker) {
            hourRangePickerSheet
        }
    }

    private var hourRangePickerSheet: some View {
        NavigationStack {
            Form {
                Picker("Start Hour", selection: $presenter.startHour) {
                    ForEach(0..<24) { hour in
                        Text(hourLabel(hour)).tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                Picker("End Hour", selection: $presenter.endHour) {
                    ForEach(0..<24) { hour in
                        Text(hourLabel(hour)).tag(hour)
                    }
                }
                .pickerStyle(.wheel)
            }
            .navigationTitle("Hour Range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presenter.isShowingHourRangePicker = false
                    }
                }
            }
        }
    }

    private func hourLabel(_ hour: Int) -> String {
        switch hour {
        case 0: return "12 AM"
        case 12: return "12 PM"
        case 1..<12: return "\(hour) AM"
        default: return "\(hour - 12) PM"
        }
    }
}

extension CoreBuilder {

    func foodLogSettingsView(router: AnyRouter, delegate: FoodLogSettingsDelegate) -> some View {
        FoodLogSettingsView(
            presenter: FoodLogSettingsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }

}

extension CoreRouter {

    func showFoodLogSettingsView(delegate: FoodLogSettingsDelegate) {
        router.showScreen(.push) { router in
            builder.foodLogSettingsView(router: router, delegate: delegate)
        }
    }

}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = FoodLogSettingsDelegate()

    return RouterView { router in
        builder.foodLogSettingsView(router: router, delegate: delegate)
    }

}
