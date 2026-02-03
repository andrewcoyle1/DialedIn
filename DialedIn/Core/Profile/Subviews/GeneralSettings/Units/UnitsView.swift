import SwiftUI

struct UnitsDelegate {
    
}

struct UnitsView: View {
    
    @State var presenter: UnitsPresenter
    let delegate: UnitsDelegate
        
    var body: some View {
        List {
            weightSection
            heightSection
            clockSection
            distanceSection
        }
        .navigationTitle("Units")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "UnitsView")
    }
    
    private var weightSection: some View {
        Picker(selection: $presenter.weightUnit) {
            Section {
                Text(WeightUnitPreference.kilograms.displayName)
                    .tag(WeightUnitPreference.kilograms)
                Text(WeightUnitPreference.pounds.displayName)
                    .tag(WeightUnitPreference.pounds)
            }
        } label: {
            Text("Weight Units")
        }
        .pickerStyle(.inline)
    }

    private var heightSection: some View {
        Picker(selection: $presenter.heightUnit) {
            Section {
                Text(HeightUnitPreference.centimeters.displayName)
                    .tag(HeightUnitPreference.centimeters)
                Text(HeightUnitPreference.inches.displayName)
                    .tag(HeightUnitPreference.inches)
            }
        } label: {
            Text("Height Units")
        }
        .pickerStyle(.inline)
    }
    
    private var clockSection: some View {
        Picker(selection: $presenter.clockUnit) {
            Section {
                Text(ClockUnitPreference.twelveHour.displayName)
                    .tag(ClockUnitPreference.twelveHour)
                Text(ClockUnitPreference.twentyFourHour.displayName)
                    .tag(ClockUnitPreference.twentyFourHour)
            }
        } label: {
            Text("Clock Units")
        }
        .pickerStyle(.inline)
    }

    private var distanceSection: some View {
        Picker(selection: $presenter.distanceUnit) {
            Section {
                Text(LengthUnitPreference.centimeters.displayName)
                    .tag(LengthUnitPreference.centimeters)
                Text(LengthUnitPreference.inches.displayName)
                    .tag(LengthUnitPreference.inches)
            }
        } label: {
            Text("Distance Units")
        }
        .pickerStyle(.inline)
    }

}

extension CoreBuilder {
    
    func unitsView(router: Router, delegate: UnitsDelegate) -> some View {
        UnitsView(
            presenter: UnitsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showUnitsView(delegate: UnitsDelegate) {
        router.showScreen(.push) { router in
            builder.unitsView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = UnitsDelegate()
    
    return RouterView { router in
        builder.unitsView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
