//
//  ProfileEditView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import PhotosUI
import SwiftfulRouting

struct ProfileEditView: View {

    @State var presenter: ProfileEditPresenter

    var body: some View {
        List {
            imageSection
            profileSection
            personalSection
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await presenter.saveProfile()
                    }
                } label: {
                    if presenter.isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                            .fontWeight(.semibold)
                    }
                }
                .disabled(presenter.isSaving || !presenter.canSave)
            }
        }
        .onAppear(perform: presenter.prefillFromCurrentUser)
        .onChange(of: presenter.selectedPhotoItem) {
            guard let newItem = presenter.selectedPhotoItem else { return }
            
            Task {
                do {
                    if let data = try await newItem.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            presenter.selectedImageData = data
                            presenter.trackPhotoSelected()
                        }
                    }
                } catch {
                    await MainActor.run {
                        presenter.trackPhotoLoadFailed(error: error)
                    }
                }
            }
        }
    }
    
    private var imageSection: some View {
        Section("Profile Photo") {
            HStack {
                Spacer()
                Button {
                    presenter.presentImagePicker()
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
                                }
                                #elseif canImport(AppKit)
                                if let nsImage = NSImage(data: data) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .scaledToFill()
                                }
                                #endif
                            } else if let user = presenter.currentUser {
                                // Use cached image
                                if let cachedImage = ProfileImageCache.shared.getCachedImage(userId: user.userId) {
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
                                    Image(systemName: "person.crop.circle")
                                        .font(.system(size: 80))
                                        .foregroundStyle(.accent)
                                }
                            } else {
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 80))
                                    .foregroundStyle(.accent)
                            }
                        }
                    }
                    .frame(width: 120, height: 120)
                    .cornerRadius(60)
                    .clipped()
                }
                .photosPicker(isPresented: $presenter.isImagePickerPresented, selection: $presenter.selectedPhotoItem, matching: .images)
                Spacer()
            }
        }
        .removeListRowFormatting()
    }
    
    private var profileSection: some View {
        Section("Name") {
            TextField("First name", text: $presenter.firstName)
                .textContentType(.givenName)
                .autocapitalization(.words)
            TextField("Last name (optional)", text: $presenter.lastName)
                .textContentType(.familyName)
                .autocapitalization(.words)
        }
    }
    
    private var personalSection: some View {
        Section("Personal Details") {
            DatePicker("Date of birth", selection: $presenter.dateOfBirth, displayedComponents: .date)
            Picker("Gender", selection: $presenter.selectedGender) {
                Text("Not specified").tag(nil as Gender?)
                Text("Male").tag(Gender.male as Gender?)
                Text("Female").tag(Gender.female as Gender?)
            }
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.profileEditView(router: router)
    }
    .previewEnvironment()
}
