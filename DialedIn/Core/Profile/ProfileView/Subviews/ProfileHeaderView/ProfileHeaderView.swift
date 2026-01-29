//
//  ProfileHeaderView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import SwiftfulRouting

struct ProfileHeaderView: View {

    @State var presenter: ProfileHeaderPresenter

    var body: some View {
        Section {
            if let user = presenter.currentUser {
                    HStack(spacing: 16) {
                        // Profile Image
                        CachedProfileImageView(
                            userId: user.userId,
                            imageUrl: user.profileImageUrl,
                            size: 60
                        )
                        
                        // User Info
                        VStack(alignment: .leading, spacing: 6) {
                            Text(fullName)
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            if let email = presenter.currentUser?.email {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                        }
                        Spacer()

                        Image(systemName: "chevron.right")
                    }
                    .tappableBackground()
                    .anyButton(.highlight) {
                        presenter.navToProfileEdit()
                    }
            }
        }
    }
    
    private var fullName: String {
        guard let user = presenter.currentUser else { return "" }
        let first = user.firstName ?? ""
        let last = user.lastName ?? ""
        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }
}

extension CoreBuilder {
    func profileHeaderView(router: AnyRouter) -> some View {
        ProfileHeaderView(
            presenter: ProfileHeaderPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container())
    RouterView { router in
        List {
            builder.profileHeaderView(router: router)
        }
    }
    .previewEnvironment()
}
