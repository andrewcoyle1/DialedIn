//
//  ProfileButton.swift
//  DialedIn
//
//  Created by Andrew Coyle on 18/03/2026.
//

import SwiftUI

struct ProfileButton: View {
    
    let avatarSize: CGFloat = 36
    let action: () -> Void
    let imageUrl: String?
    
    var body: some View {
        Button {
            action()
        } label: {
            Group {
                if let imageUrl {
                    ImageLoaderView(urlString: imageUrl, clipShape: AnyShape(Circle()))
                        .frame(width: avatarSize, height: avatarSize)
                } else {
                    Image(systemName: "person.circle")
                        .font(.system(size: 24))

                }
            }
        }
        .buttonStyle(.plain)
        .buttonBorderShape(.circle)

    }
}

#Preview {
    NavigationStack {
        Color.clear.ignoresSafeArea()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ProfileButton(
                        action: {
                            
                        },
                        imageUrl: Constants.randomImage
                    )
                }
            }
    }
}
