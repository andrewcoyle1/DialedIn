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

    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isImagePickerPresented: Bool = false
    
    @State private var isSaving: Bool = false
    @State private var showAlert: AnyAppAlert?
    @State private var navigateToGender: Bool = false
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    private var canContinue: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
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
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(container: container))
        }
        #endif
        .onAppear(perform: prefillFromCurrentUser)
        .onChange(of: selectedPhotoItem) {
            guard let newItem = selectedPhotoItem else { return }
            
            Task {
                do {
                    if let data = try await newItem.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            selectedImageData = data
                            logManager.trackEvent(eventName: "profile_photo_selected")
                        }
                    } else {
                        await MainActor.run {
                            logManager.trackEvent(eventName: "profile_photo_load_empty")
                        }
                    }
                } catch {
                    await MainActor.run {
                        logManager.trackEvent(eventName: "profile_photo_load_failed", parameters: ["error": String(describing: error)])
                    }
                }
            }
        }
        .showCustomAlert(alert: $showAlert)
        .showModal(showModal: $isSaving) {
            ProgressView()
                .tint(.white)
        }
        .navigationDestination(isPresented: $navigateToGender) {
            OnboardingGenderView()
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack {
                Spacer()
                Button {
                    isImagePickerPresented = true
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.001))
                        Group {
                            if let data = selectedImageData {
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
                            } else if let user = userManager.currentUser,
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
                .photosPicker(isPresented: $isImagePickerPresented, selection: $selectedPhotoItem, matching: .images)
                Spacer()
            }
        }
        .removeListRowFormatting()
    }
    
    private var nameSection: some View {
        Section("Your Name") {
            TextField("First name", text: $firstName)
                .textContentType(.givenName)
                .autocapitalization(.words)
            TextField("Last name (optional)", text: $lastName)
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
                showDebugView = true
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                Task {
                    await saveAndContinue()
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(isSaving || !canContinue)
        }
    }
    
    private func prefillFromCurrentUser() {
        guard let user = userManager.currentUser else { return }
        firstName = user.firstName ?? firstName
        lastName = user.lastName ?? lastName
        // Note: We don't prefill the image as it would require fetching from URL
    }
    
    private func saveAndContinue() async {
        guard canContinue else { return }
        isSaving = true
        
        do {
            guard let userId = userManager.currentUser?.userId else {
                logManager.trackEvent(eventName: "name_photo_save_failed", parameters: ["error": "Missing current user ID"])
                isSaving = false
                return
            }
            
            let trimmedFirst = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedLast = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let user = UserModel(
                userId: userId,
                email: userManager.currentUser?.email,
                isAnonymous: userManager.currentUser?.isAnonymous,
                firstName: trimmedFirst,
                lastName: trimmedLast.isEmpty ? nil : trimmedLast
            )
            
            #if canImport(UIKit)
            let uiImage = selectedImageData.flatMap { UIImage(data: $0) }
            try await userManager.saveUser(user: user, image: uiImage)
            #elseif canImport(AppKit)
            let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
            try await userManager.saveUser(user: user, image: nsImage)
            #endif
            
            logManager.trackEvent(eventName: "name_photo_save_success")
            isSaving = false
            navigateToGender = true
        } catch {
            logManager.trackEvent(eventName: "name_photo_save_failed", parameters: ["error": String(describing: error)])
            showAlert = AnyAppAlert(
                title: "Unable to save",
                subtitle: "Please check your internet connection and try again."
            )
            isSaving = false
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingNamePhotoView()
    }
    .previewEnvironment()
}

#Preview("Slow Loading") {
    NavigationStack {
        OnboardingNamePhotoView()
    }
    .environment(UserManager(services: MockUserServices(user: .mock, delay: 3)))
    .previewEnvironment()
}
