//
//  OnboardingNamePhotoView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import PhotosUI

struct OnboardingNamePhotoView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingNamePhotoViewModel
    
    var body: some View {
        List {
            imageSection
            nameSection
            descriptionSection
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Create Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(
                viewModel: DevSettingsViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                )
            )
        }
        #endif
        .onAppear(perform: viewModel.prefillFromCurrentUser)
        .onChange(of: viewModel.selectedPhotoItem) {
            Task {
                await viewModel.handlePhotoSelection()
            }
        }
        .showCustomAlert(alert: $viewModel.showAlert)
        .showModal(showModal: $viewModel.isSaving) {
            ProgressView()
                .tint(.white)
        }
        .navigationDestination(isPresented: $viewModel.navigateToGender) {
            OnboardingGenderView(
                viewModel: OnboardingGenderViewModel(
                    interactor: CoreInteractor(
                        container: container
                    )
                )
            )
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack {
                Spacer()
                Button {
                    viewModel.isImagePickerPresented = true
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.001))
                        Group {
                            if let data = viewModel.selectedImageData {
                                #if canImport(UIKit)
                                if let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                }
                                #elseif canImport(AppKit)
                                if let nsImage = NSImage(data: data) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .scaledToFill()
                                }
                                #endif
                            } else if let user = viewModel.currentUser,
                                      let cachedImage = ProfileImageCache.shared.getCachedImage(userId: user.userId) {
                                // Show cached image if available
                                #if canImport(UIKit)
                                Image(uiImage: cachedImage)
                                    .resizable()
                                    .scaledToFill()
                                #elseif canImport(AppKit)
                                Image(nsImage: cachedImage)
                                    .resizable()
                                    .scaledToFill()
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
                    .frame(width: 120, height: 120)
                    .cornerRadius(60)
                    .clipped()
                }
                .photosPicker(isPresented: $viewModel.isImagePickerPresented, selection: $viewModel.selectedPhotoItem, matching: .images)
                Spacer()
            }
        }
        .removeListRowFormatting()
    }
    
    private var nameSection: some View {
        Section("Your Name") {
            TextField("First name", text: $viewModel.firstName)
                .textContentType(.givenName)
                .autocapitalization(.words)
            TextField("Last name (optional)", text: $viewModel.lastName)
                .textContentType(.familyName)
                .autocapitalization(.words)
        }
    }
    
    private var descriptionSection: some View {
        Section {
            Text("Help us personalize your experience by providing your name. You can also add a profile photo if you'd like.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .removeListRowFormatting()
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                Task {
                    await viewModel.saveAndContinue()
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.isSaving || !viewModel.canContinue)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingNamePhotoView(
            viewModel: OnboardingNamePhotoViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            )
        )
    }
    .previewEnvironment()
}
