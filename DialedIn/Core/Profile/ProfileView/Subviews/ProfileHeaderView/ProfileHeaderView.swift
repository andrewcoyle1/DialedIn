//
//  ProfileHeaderView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI
import CustomRouting

struct ProfileHeaderView: View {

    @State var presenter: ProfileHeaderPresenter

    var body: some View {
        Section {
            if let user = presenter.currentUser {
                Button {
                    presenter.navToProfileEdit()
                } label: {
                    HStack(spacing: 16) {
                        // Profile Image
                        CachedProfileImageView(
                            userId: user.userId,
                            imageUrl: user.profileImageUrl,
                            size: 80
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
                            
                            if let creationDate = presenter.currentUser?.creationDate {
                                Text("Member since \(creationDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .removeListRowFormatting()
    }
    
    private var fullName: String {
        guard let user = presenter.currentUser else { return "" }
        let first = user.firstName ?? ""
        let last = user.lastName ?? ""
        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        List {
            builder.profileHeaderView(router: router)
        }
    }
    .previewEnvironment()
}
