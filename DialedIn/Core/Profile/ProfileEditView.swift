//
//  ProfileEditView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 20/10/2025.
//

import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var selectedGender: Gender?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isImagePickerPresented: Bool = false
    
    @State private var isSaving: Bool = false
    @State private var showAlert: AnyAppAlert?
    
    private var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
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
                        await saveProfile()
                    }
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Save")
                            .fontWeight(.semibold)
                    }
                }
                .disabled(isSaving || !canSave)
            }
        }
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
                    }
                } catch {
                    await MainActor.run {
                        logManager.trackEvent(eventName: "profile_photo_load_failed", parameters: ["error": String(describing: error)])
                    }
                }
            }
        }
        .showCustomAlert(alert: $showAlert)
    }
    
    private var imageSection: some View {
        Section("Profile Photo") {
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
                            } else if let user = userManager.currentUser {
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
                .photosPicker(isPresented: $isImagePickerPresented, selection: $selectedPhotoItem, matching: .images)
                Spacer()
            }
        }
        .removeListRowFormatting()
    }
    
    private var profileSection: some View {
        Section("Name") {
            TextField("First name", text: $firstName)
                .textContentType(.givenName)
                .autocapitalization(.words)
            TextField("Last name (optional)", text: $lastName)
                .textContentType(.familyName)
                .autocapitalization(.words)
        }
    }
    
    private var personalSection: some View {
        Section("Personal Details") {
            DatePicker("Date of birth", selection: $dateOfBirth, displayedComponents: .date)
            Picker("Gender", selection: $selectedGender) {
                Text("Not specified").tag(nil as Gender?)
                Text("Male").tag(Gender.male as Gender?)
                Text("Female").tag(Gender.female as Gender?)
            }
        }
    }
    
    private func prefillFromCurrentUser() {
        guard let user = userManager.currentUser else { return }
        firstName = user.firstName ?? ""
        lastName = user.lastName ?? ""
        if let dob = user.dateOfBirth {
            dateOfBirth = dob
        }
        selectedGender = user.gender
    }
    
    private func saveProfile() async {
        guard canSave else { return }
        isSaving = true
        
        do {
            guard let userId = userManager.currentUser?.userId else {
                logManager.trackEvent(eventName: "profile_edit_save_failed", parameters: ["error": "Missing current user ID"])
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
                lastName: trimmedLast.isEmpty ? nil : trimmedLast,
                dateOfBirth: dateOfBirth,
                gender: selectedGender
            )
            
            #if canImport(UIKit)
            let uiImage = selectedImageData.flatMap { UIImage(data: $0) }
            try await userManager.saveUser(user: user, image: uiImage)
            #elseif canImport(AppKit)
            let nsImage = selectedImageData.flatMap { NSImage(data: $0) }
            try await userManager.saveUser(user: user, image: nsImage)
            #endif
            
            logManager.trackEvent(eventName: "profile_edit_save_success")
            dismiss()
        } catch {
            logManager.trackEvent(eventName: "profile_edit_save_failed", parameters: ["error": String(describing: error)])
            showAlert = AnyAppAlert(
                title: "Unable to save",
                subtitle: "Please check your internet connection and try again."
            )
        }
        isSaving = false
    }
}

#Preview {
    NavigationStack {
        ProfileEditView()
    }
    .previewEnvironment()
}
