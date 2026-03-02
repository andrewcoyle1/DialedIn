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
                    symbolName: "",
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
                    subtitle: "7 AM - 11 PM") {
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
                    subtitle: "Left Aligned") {
                        Text("Edit")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {
                                presenter.onEditAlignmentPressed()
                            }
                    }
                CustomLabelButtonView(
                    symbolName: "clock",
                    title: "Add Foods to Hour",
                    subtitle: "Plus icon next to each hour") {
                        Text("Edit")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
                            .anyButton(.press) {
                                presenter.onEditAddFoodsToHourPressed()
                            }
                    }
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
                    title: "Hour Range",
                    subtitle: "7 AM - 11 PM",
                    bool: $presenter.premove
                )
            } header: {
                Text("Timeline Options")
            }

            Section {
                CustomToggleView(
                    symbolName: "",
                    title: "Branded Results",
                    subtitle: presenter.showBrandedFoods ? "On" : "Off",
                    bool: $presenter.showBrandedFoods
                )
                CustomToggleView(
                    symbolName: "",
                    title: "Open Food Facts Results",
                    subtitle: presenter.showOpenFoodFactsFoods ? "On" : "Off",
                    bool: $presenter.showOpenFoodFactsFoods
                )
            } header: {
                Text("Food Search")
            }

            Section {
                CustomLabelButtonView(
                    symbolName: "",
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
                    symbolName: "",
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
                    symbolName: "",
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
                    symbolName: "",
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
                    symbolName: "",
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
                    symbolName: "clock",
                    title: "Optimisation",
                    subtitle: "Optimise for speed") {
                        Text("Edit")
                            .padding(.horizontal, 8)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2), in: .capsule)
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
