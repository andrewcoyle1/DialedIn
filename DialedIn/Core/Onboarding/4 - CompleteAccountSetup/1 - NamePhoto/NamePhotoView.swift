//
//  NamePhotoView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import PhotosUI

struct NamePhotoView: View {
    
    @State var presenter: NamePhotoPresenter
    
    var body: some View {
        List {
            imageSection
            nameSection
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Create Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        .onAppear(perform: presenter.prefillFromCurrentUser)
        .onChange(of: presenter.selectedPhotoItem) {
            Task {
                await presenter.handlePhotoSelection()
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                presenter.saveAndContinue()
            } label: {
                Text("Continue")
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .disabled(!presenter.canContinue)
            .padding(.horizontal)
        }
    }
    
    private var imageSection: some View {
        ZStack {
            Rectangle()
                .fill(Color.secondary.opacity(0.001))
            Group {
                if let data = presenter.selectedImageData {
                    Group {
#if canImport(UIKit)
                        if let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .aspectRatio(1, contentMode: .fit)
                        }
#elseif canImport(AppKit)
                        if let nsImage = NSImage(data: data) {
                            Image(nsImage: nsImage)
                                .resizable()
                                .scaledToFill()
                                .aspectRatio(1, contentMode: .fit)
                        }
#endif
                    }
                    .clipShape(Circle())
                    
                } else if let user = presenter.currentUser,
                          let cachedImage = ProfileImageCache.shared.getCachedImage(userId: user.userId) {
                    Group {
                        // Show cached image if available
#if canImport(UIKit)
                        Image(uiImage: cachedImage)
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(1, contentMode: .fit)
#elseif canImport(AppKit)
                        Image(nsImage: cachedImage)
                            .resizable()
                            .scaledToFill()
                            .aspectRatio(1, contentMode: .fit)
#endif
                    }
                    .clipShape(Circle())
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 80))
                            .foregroundStyle(.accent)
                            .clipShape(Circle())
                        
                        Text("Add Photo (Optional)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .anyButton {
            presenter.isImagePickerPresented = true
            
        }
        .photosPicker(isPresented: $presenter.isImagePickerPresented, selection: $presenter.selectedPhotoItem, matching: .images)
        .removeListRowFormatting()
    }
    
    private var nameSection: some View {
        Section {
            TextField("First name", text: $presenter.firstName)
                .textContentType(.givenName)
                .autocapitalization(.words)
            TextField("Last name (optional)", text: $presenter.lastName)
                .textContentType(.familyName)
                .autocapitalization(.words)
        } header: {
            Text("Your Name")
        } footer: {
            Text("Help us personalize your experience by providing your name. You can also add a profile photo if you'd like.")
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
#if DEBUG || MOCK
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
#endif
    }
}

extension CoreBuilder {
    func namePhotoView(router: AnyRouter) -> some View {
        NamePhotoView(
            presenter: NamePhotoPresenter(interactor: interactor, router: CoreRouter(router: router, builder: self))
        )
    }
}

extension CoreRouter {
    func showNamePhotoView() {
        router.showScreen(.push) { router in
            builder.namePhotoView(router: router)
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.namePhotoView(router: router)
    }
    
}
