import SwiftUI

struct GymProfilesView: View {
    
    @State var presenter: GymProfilesPresenter
    
    var body: some View {
        List {
            gymProfilesSection
        }
        .navigationTitle("Gym Profiles")
        .navigationBarTitleDisplayMode(.inline)
        .screenAppearAnalytics(name: "GymProfilesView")
        .toolbar {
            toolbarContent
        }
        .onAppear {
            presenter.loadLocalGymProfiles()
        }
        .onFirstTask {
            await presenter.loadRemoteGymProfiles()
        }
    }
    
    private var gymProfilesSection: some View {
        Section {
            ForEach(presenter.gymProfiles) { profile in
                CustomListCellView(
                    imageName: profile.imageUrl,
                    title: profile.name,
                    subtitle: equipmentSubtitle(for: profile)
                )
                .anyButton {
                    presenter.onGymProfilePressed(gymProfile: profile)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        presenter.deleteGymProfile(profile: profile)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        presenter.favouriteGymProfile(profile: profile)
                    } label: {
                        Label("Favourite", systemImage: "star")
                    }
                    .tint(.accent)
                }
            }
            .removeListRowFormatting()

        } header: {
            Text(String.countCaption(count: presenter.numGyms, unit: "Gym"))
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {

        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDismissPressed()
            } label: {
                Image(systemName: "xmark")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onAddGymProfilePressed()
            } label: {
                Image(systemName: "plus")
            }
        }
    }

    private func equipmentSubtitle(for profile: GymProfileModel) -> String {
        let count = profile.activeEquipmentCount
        let pieceLabel = count == 1 ? "piece" : "pieces"
        return "\(count) active \(pieceLabel) of equipment"
    }
}

extension CoreBuilder {
    
    func gymProfilesView(router: Router) -> some View {
        GymProfilesView(
            presenter: GymProfilesPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
    
}

extension CoreRouter {
    
    func showGymProfilesView() {
        router.showScreen(.fullScreenCover) { router in
            builder.gymProfilesView(router: router)
        }
    }
    
}

#Preview {
    let container = DevPreview.shared.container
    let builder = CoreBuilder(interactor: CoreInteractor(container: container))
    
    return RouterView { router in
        builder.gymProfilesView(router: router)
    }
    .previewEnvironment()
}
