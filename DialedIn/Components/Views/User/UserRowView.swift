//
//  UserRowView.swift
//  DialedIn
//
//  One avatar and one person-row, shared by every screen that lists people. The Add tab's search
//  results, the followers list and the social profile each had their own copy, at three different
//  sizes with three different fallbacks for a missing picture.
//

import SwiftUI

/// A person's picture, falling back to the system person glyph.
struct UserAvatarView: View {

    let imageUrl: String?
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.secondary)

            if let imageUrl {
                ImageLoaderView(urlString: imageUrl, clipShape: AnyShape(Circle()))
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

/// A person in a list: picture, name, and whatever the screen wants on the trailing edge.
struct UserRowView<Trailing: View>: View {

    let user: UserModel
    var avatarSize: CGFloat = 44
    @ViewBuilder var trailing: () -> Trailing

    private var displayName: String {
        user.fullNameCalculated ?? user.firstNameCalculated ?? "Unknown"
    }

    var body: some View {
        HStack(spacing: 12) {
            UserAvatarView(imageUrl: user.profileImageNameCalculated, size: avatarSize)

            Text(displayName)
                .font(.body.weight(.medium))
                .lineLimit(1)

            Spacer(minLength: 0)

            trailing()
        }
        .padding(.vertical, 6)
    }
}

extension UserRowView where Trailing == EmptyView {

    init(user: UserModel, avatarSize: CGFloat = 44) {
        self.init(user: user, avatarSize: avatarSize, trailing: { EmptyView() })
    }
}

/// The follow/unfollow pill shown beside a person in search results.
struct FollowButton: View {

    let isFollowing: Bool
    let onFollowPressed: () -> Void
    let onUnfollowPressed: () -> Void

    var body: some View {
        Button {
            if isFollowing {
                onUnfollowPressed()
            } else {
                onFollowPressed()
            }
        } label: {
            Text(isFollowing ? "Following" : "Follow")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isFollowing ? Color(.secondarySystemBackground) : Color.accentColor)
                .foregroundStyle(isFollowing ? Color.primary : Color.white)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    List {
        UserRowView(user: .mock)
        UserRowView(user: .mock) {
            FollowButton(isFollowing: false, onFollowPressed: { }, onUnfollowPressed: { })
        }
        UserRowView(user: .mock) {
            FollowButton(isFollowing: true, onFollowPressed: { }, onUnfollowPressed: { })
        }
    }
}
