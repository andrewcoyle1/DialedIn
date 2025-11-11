//
//  ProfileHeaderView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

struct ProfileHeaderView: View {
    @State var viewModel: ProfileHeaderViewModel

    @Binding var path: [TabBarPathOption]

    var body: some View {
        Section {
            if let user = viewModel.currentUser {
                Button {
                    viewModel.navToProfileEdit(path: $path)
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
                            
                            if let email = viewModel.currentUser?.email {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if let creationDate = viewModel.currentUser?.creationDate {
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
        guard let user = viewModel.currentUser else { return "" }
        let first = user.firstName ?? ""
        let last = user.lastName ?? ""
        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }
}

#Preview {
    @Previewable @State var path: [TabBarPathOption] = []
    List {
        ProfileHeaderView(
            viewModel: ProfileHeaderViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ),
            path: $path
        )
    }
    .previewEnvironment()
}
