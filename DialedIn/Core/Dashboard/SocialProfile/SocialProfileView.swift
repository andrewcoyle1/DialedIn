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
            
            dataSection
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
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
                    ZStack {
                        Image(systemName: "person.circle")
                            .resizable()
                            .font(.system(size: 24))
                        if let urlString = delegate.user.profileImageNameCalculated {
                            ImageLoaderView(urlString: urlString, clipShape: AnyShape(Circle()))
                                .contentShape(Circle())
                        }
                    }
                    .frame(width: 80, height: 80)
                    
                    VStack {
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
                    StatItem(header: "Activity", value: "1")
                    Button {
                        presenter.onFollowersPressed()
                    } label: {
                        StatItem(header: "Followers", value: "\(presenter.followersCount)")
                    }
                    .buttonStyle(.plain)
                    StatItem(header: "Following", value: "\(presenter.followingCount)")
                    Spacer()
                    Image(systemName: "bubble.left.and.bubble.right")
                        .anyButton(.press) {
                            presenter.onChatPressed(user: delegate.user)
                        }
                }
                
                mutualFollowersImagesSection
            }
            
        }
    }
    
    private var dataSection: some View {
        Section {
            CustomLabelButtonView(
                symbolName: "",
                title: "Activities",
                subtitle: "Yesterday") {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .padding()
                        .anyButton(.press) {
                            
                        }
                }
            CustomLabelButtonView(
                symbolName: "",
                title: "Statistics",
                subtitle: "This year: 93.0 km") {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .padding()
                        .anyButton(.press) {
                            
                        }
                }
            CustomLabelButtonView(
                symbolName: "",
                title: "Routes",
                subtitle: "-") {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .padding()
                        .anyButton(.press) {
                            
                        }
                }
            CustomLabelButtonView(
                symbolName: "",
                title: "Segments",
                subtitle: "-") {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .padding()
                        .anyButton(.press) {
                            
                        }
                }
            CustomLabelButtonView(
                symbolName: "",
                title: "Best Efforts",
                subtitle: "See all") {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .padding()
                        .anyButton(.press) {
                            
                        }
                }
            CustomLabelButtonView(
                symbolName: "",
                title: "Posts",
                subtitle: "1") {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .padding()
                        .anyButton(.press) {
                            
                        }
                }
            CustomLabelButtonView(
                symbolName: "shoe",
                title: "Gear",
                subtitle: "Puma Deviate Nitro") {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .padding()
                        .anyButton(.press) {
                            
                        }
                }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            Button {
                
            } label: {
                Image(systemName: "ellipsis")
            }
        }
    }
    
    private var mutualFollowersImagesSection: some View {
        HStack(spacing: -10) {
            ForEach(presenter.mutualFollowers.prefix(5)) { user in
                mutualFollowersImageCircle(user: user)
            }
            HStack {
                Text("People you both follow")
                Spacer()
                Text("See all")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.leading)
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
