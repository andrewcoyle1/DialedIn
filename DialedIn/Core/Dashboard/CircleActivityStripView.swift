//
//  CircleActivityStripView.swift
//  DialedIn
//
//  The row of faces at the top of the Dashboard feed: who in the user's circle has trained today.
//

import SwiftUI

/// One person in the strip, derived by `DashboardPresenter.circleMembers`.
struct CircleMember: Identifiable {
    let user: UserModel
    /// Finished a non-rest session today, by the device's calendar.
    let trainedToday: Bool
    /// Not trained, not the user, and not already nudged today.
    let canNudge: Bool

    var id: String { user.userId }

    var name: String {
        user.commonNameCalculated ?? user.fullNameCalculated ?? "Unknown"
    }
}

/// Full colour with a check for anyone who has trained today, greyed otherwise. The nudge is a
/// visible button under the greyed face rather than a long-press menu: a context menu on an
/// avatar is invisible until someone happens to hold it, and the nudge is the point of the strip.
struct CircleActivityStripView: View {

    let members: [CircleMember]
    let onMemberPressed: (CircleMember) -> Void
    let onNudgePressed: (CircleMember) -> Void

    private let avatarSize: CGFloat = 52

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(members) { member in
                    memberCell(member)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
    }

    private func memberCell(_ member: CircleMember) -> some View {
        VStack(spacing: 6) {
            Button {
                onMemberPressed(member)
            } label: {
                VStack(spacing: 4) {
                    avatar(member)
                    Text(member.name)
                        .font(.caption)
                        .foregroundStyle(member.trainedToday ? .primary : .secondary)
                        .lineLimit(1)
                }
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(member.name), \(member.trainedToday ? "trained today" : "not trained yet today")")
            .accessibilityHint("Opens their profile")

            if member.canNudge {
                Button("Nudge") {
                    onNudgePressed(member)
                }
                .font(.caption2.weight(.semibold))
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .controlSize(.mini)
                .accessibilityLabel("Nudge \(member.name) to train")
            }
        }
        .frame(width: avatarSize + 12)
    }

    private func avatar(_ member: CircleMember) -> some View {
        UserAvatarView(imageUrl: member.user.profileImageNameCalculated, size: avatarSize)
            .grayscale(member.trainedToday ? 0 : 1)
            .opacity(member.trainedToday ? 1 : 0.5)
            .overlay(alignment: .bottomTrailing) {
                if member.trainedToday {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(.white, .green)
                        .background(Circle().fill(.background))
                }
            }
    }
}

#Preview {
    CircleActivityStripView(
        members: [
            CircleMember(user: .mock, trainedToday: true, canNudge: false),
            CircleMember(user: UserModel(userId: "b", submittedFirstName: "Sam"), trainedToday: false, canNudge: true),
            CircleMember(user: UserModel(userId: "c", submittedFirstName: "Alex"), trainedToday: false, canNudge: false)
        ],
        onMemberPressed: { _ in },
        onNudgePressed: { _ in }
    )
}
