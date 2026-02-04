import SwiftUI

struct ChooseGymProfileDelegate {
    let name: String
}

struct ChooseGymProfileView: View {
    
    @State var presenter: ChooseGymProfilePresenter
    let delegate: ChooseGymProfileDelegate
    
    var body: some View {
        List {
            Section {
                ForEach(presenter.gymProfiles) { profile in
                    CustomListCellView(
                        imageName: profile.imageUrl,
                        title: profile.name,
                        subtitle: equipmentSubtitle(for: profile)
                    )
                    .anyButton {
                        presenter.onGymProfilePressed(name: delegate.name, profile: profile)
                    }
                }
                .removeListRowFormatting()
            } header: {
                Text("This will be associated with the workout template.")
            }
        }
        .navigationTitle("Choose Gym Profile")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "ChooseGymProfileView")
    }
    
    private func equipmentSubtitle(for profile: GymProfileModel) -> String {
        let count = profile.activeEquipmentCount
        let pieceLabel = count == 1 ? "piece" : "pieces"
        return "\(count) active \(pieceLabel) of equipment"
    }

}

extension CoreBuilder {
    
    func chooseGymProfileView(router: Router, delegate: ChooseGymProfileDelegate) -> some View {
        ChooseGymProfileView(
            presenter: ChooseGymProfilePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showChooseGymProfileView(delegate: ChooseGymProfileDelegate) {
        router.showScreen(.push) { router in
            builder.chooseGymProfileView(router: router, delegate: delegate)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container()
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    let delegate = ChooseGymProfileDelegate(name: "Preview Workout")
    
    return RouterView { router in
        builder.chooseGymProfileView(router: router, delegate: delegate)
    }
    .previewEnvironment()
}
