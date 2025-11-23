//
//  ProfileEditView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import PhotosUI
import CustomRouting

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: ProfileEditViewModel
    
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
                        await viewModel.saveProfile(onDismiss: { dismiss() })
                    }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                            .fontWeight(.semibold)
                    }
                }
                .disabled(viewModel.isSaving || !viewModel.canSave)
            }
        }
        .onAppear(perform: viewModel.prefillFromCurrentUser)
        .onChange(of: viewModel.selectedPhotoItem) {
            guard let newItem = viewModel.selectedPhotoItem else { return }
            
            Task {
                do {
                    if let data = try await newItem.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            viewModel.selectedImageData = data
                            viewModel.trackPhotoSelected()
                        }
                    }
                } catch {
                    await MainActor.run {
                        viewModel.trackPhotoLoadFailed(error: error)
                    }
                }
            }
        }
        .showCustomAlert(alert: $viewModel.showAlert)
    }
    
    private var imageSection: some View {
        Section("Profile Photo") {
            HStack {
                Spacer()
                Button {
                    viewModel.presentImagePicker()
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
                            } else if let user = viewModel.currentUser {
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
                .photosPicker(isPresented: $viewModel.isImagePickerPresented, selection: $viewModel.selectedPhotoItem, matching: .images)
                Spacer()
            }
        }
        .removeListRowFormatting()
    }
    
    private var profileSection: some View {
        Section("Name") {
            TextField("First name", text: $viewModel.firstName)
                .textContentType(.givenName)
                .autocapitalization(.words)
            TextField("Last name (optional)", text: $viewModel.lastName)
                .textContentType(.familyName)
                .autocapitalization(.words)
        }
    }
    
    private var personalSection: some View {
        Section("Personal Details") {
            DatePicker("Date of birth", selection: $viewModel.dateOfBirth, displayedComponents: .date)
            Picker("Gender", selection: $viewModel.selectedGender) {
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
