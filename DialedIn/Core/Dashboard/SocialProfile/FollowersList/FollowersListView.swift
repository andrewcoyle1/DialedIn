import SwiftUI

struct FollowersListDelegate {
    let followers: [UserModel]
}

struct FollowersListView: View {
    
    @State var presenter: FollowersListPresenter
    let delegate: FollowersListDelegate

    var body: some View {
        List(delegate.followers) { user in
            HStack {
                ZStack {
                    Image(systemName: "person.circle")
                        .font(.system(size: 24))
                    if let url = user.profileImageNameCalculated {
                        ImageLoaderView(urlString: url, clipShape: AnyShape(Circle()))
                    }
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading) {
                    if let name = user.fullNameCalculated {
                        Text(name).font(.headline)
                    }
                }
            }
        }
        .navigationTitle("Followers")
    }
}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = FollowersListDelegate(followers: UserModel.mocks)
    
    RouterView { router in
        builder.followersListView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    func followersListView(router: AnyRouter, delegate: FollowersListDelegate) -> some View {
        FollowersListView(
            presenter: FollowersListPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
}

extension CoreRouter {
    func showFollowersList(delegate: FollowersListDelegate) {
        router.showScreen(.push) { router in
            builder.followersListView(router: router, delegate: delegate)
        }
    }
}
