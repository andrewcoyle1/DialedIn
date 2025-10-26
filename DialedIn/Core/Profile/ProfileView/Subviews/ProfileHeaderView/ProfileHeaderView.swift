//
//  ProfileHeaderView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 21/10/2025.
//

import SwiftUI

struct ProfileHeaderView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: ProfileHeaderViewModel
    
    var body: some View {
        Section {
            if let user = viewModel.currentUser {
                NavigationLink {
                    ProfileEditView(viewModel: ProfileEditViewModel(interactor: CoreInteractor(container: container)))
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
    List {
        ProfileHeaderView(viewModel: ProfileHeaderViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
    }
    .previewEnvironment()
}
