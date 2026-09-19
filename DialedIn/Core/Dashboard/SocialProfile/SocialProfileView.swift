import SwiftUI

struct SocialProfileDelegate {
    let user: UserModel
    var eventParameters: [String: Any]? {
        nil
    }
}

struct SocialProfileView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State var presenter: SocialProfilePresenter
    let delegate: SocialProfileDelegate
    
    var body: some View {
        List {
            profileSection
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        // A toolbar sat here with a share button and an ellipsis menu, both empty actions. Sharing a
        // profile needs a shareable link, and there is no user-profile deep link route (the `compound`
        // scheme has none); the ellipsis had no menu items defined at all.
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }
    
    private var profileSection: some View {
        Section {
            VStack(alignment: .leading) {
                HStack {
                    // Profile Image
                    UserAvatarView(imageUrl: delegate.user.profileImageNameCalculated, size: 80)

                    VStack(alignment: .leading) {
                        if let name = delegate.user.fullNameCalculated {
                            Text(name)
                                .font(.headline)
                        }
                        if let dob = delegate.user.submittedDateOfBirth {
                            Text(dob.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                HStack {
                    // An "Activity 1" stat sat here, hardcoded. Nothing counts a user's activity, and
                    // followers/following beside it are real, which made the fake one look real too.
                    Button {
                        presenter.onFollowersPressed()
                    } label: {
                        StatItem(header: "Followers", value: "\(presenter.followersCount)")
                    }
                    .buttonStyle(.plain)
                    StatItem(header: "Following", value: "\(presenter.followingCount)")
                    Spacer()
                    // A chat button sat here. There is no messaging anywhere in the app — no model, no
                    // manager, no screen — so it was an empty closure over a feature that does not exist.
                }
                
                if !presenter.mutualFollowers.isEmpty {
                    mutualFollowersImagesSection
                }
            }
            
        } header: {
            Text("Profile")
        }
    }
    
    // A "Data" section sat here: Activities, Statistics, Routes, Segments, Best Efforts, Posts and
    // Gear — seven rows, every action an empty closure, with invented subtitles ("This year: 93.0 km",
    // "Puma Deviate Nitro", "Yesterday"). It needs the Strava *read* API, and `StravaManager` is
    // upload-only: authenticate, uploadActivity, disconnect, and no fetch of any kind. Showing
    // someone else's mileage as fact is the worst version of this, so the section is gone rather than
    // emptied. "Posts" is the one row that maps to data the app owns — the session feed — but
    // SocialProfileInteractor cannot reach another user's sessions today. Recorded in the plan.

    private var mutualFollowersImagesSection: some View {
        HStack {
            // The avatars overlap; the label beside them must not, so the negative spacing is
            // scoped to the stack that wants it instead of the whole row.
            HStack(spacing: -10) {
                ForEach(presenter.mutualFollowers.prefix(5)) { user in
                    mutualFollowersImageCircle(user: user)
                }
            }

            Text("People you both follow")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text("See all")
                .font(.caption)
                .anyButton(.press) {
                    presenter.onMutualFollowersPressed()
                }
        }
    }

    @ViewBuilder
    private func mutualFollowersImageCircle(user: UserModel) -> some View {
        ZStack {
            Circle()
                .fill(colorScheme.backgroundPrimary)

            ImageLoaderView(
                urlString: user.submittedProfileImage ?? "SplashScreen",
                resizingMode: .fit,
                clipShape: AnyShape(Circle())
            )
        }
        .frame(width: 38, height: 38)
        .overlay(Circle().stroke(colorScheme.backgroundSecondary, lineWidth: 2))
    }

}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = SocialProfileDelegate(user: .mock)
    
    return RouterView { router in
        builder.socialProfileView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func socialProfileView(router: AnyRouter, delegate: SocialProfileDelegate) -> some View {
        SocialProfileView(
            presenter: SocialProfilePresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showSocialProfileView(delegate: SocialProfileDelegate) {
        router.showScreen(.push) { router in
            builder.socialProfileView(router: router, delegate: delegate)
        }
    }
    
}
