//
//  OnboardingNamePhotoView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import PhotosUI
import SwiftfulRouting

struct OnboardingNamePhotoView: View {

    @State var presenter: OnboardingNamePhotoPresenter

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
    }
    
    private var imageSection: some View {
        Button {
            presenter.isImagePickerPresented = true
        } label: {
            ZStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.001))
                Group {
                    if let data = presenter.selectedImageData {
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
                    } else if let user = presenter.currentUser,
                              let cachedImage = ProfileImageCache.shared.getCachedImage(userId: user.userId) {
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
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 80))
                                .foregroundStyle(.accent)
                            Text("Add Photo (Optional)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .clipShape(Circle())
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
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                Task {
                    await presenter.saveAndContinue()
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!presenter.canContinue)
        }
    }
}

extension OnbBuilder {
    func onboardingNamePhotoView(router: AnyRouter) -> some View {
        OnboardingNamePhotoView(
            presenter: OnboardingNamePhotoPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self))
        )
    }
}

extension OnbRouter {
    func showOnboardingNamePhotoView() {
        router.showScreen(.push) { router in
            builder.onboardingNamePhotoView(router: router)
        }
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingNamePhotoView(router: router)
    }
    .previewEnvironment()
}
