//
//  OnboardingCreateProfileView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import PhotosUI

struct OnboardingCreateProfileView: View {
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @State private var selectedGender: Gender?
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isImagePickerPresented: Bool = false
    
    @State private var isSaving: Bool = false
    @State private var navigateNext: Bool = false

    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    private var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        List {
            imageSection
            profileSection
            personalSection
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Create a Profile")
        .navigationBarTitleDisplayMode(.large)
        #if !DEBUG && !MOCK
        .navigationBarBackButtonHidden(true)
        #else
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showDebugView = true
                } label: {
                    Image(systemName: "info")
                }
            }
        }
        .sheet(isPresented: $showDebugView) {
            DevSettingsView()
        }
        #endif
        .onAppear(perform: prefillFromCurrentUser)
        .navigationDestination(isPresented: $navigateNext) {
            OnboardingHealthDataView()
        }
        .safeAreaInset(edge: .bottom) {
            buttonSection
        }
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
    }
    
    private var imageSection: some View {
        Section("Profile photo") {
            HStack {
                Spacer()
                Button {
                    onImageSelectorPressed()
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
                            } else {
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 120))
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
        Section("Profile") {
            TextField("First name", text: $firstName)
                .textContentType(.givenName)
                .autocapitalization(.words)
            TextField("Last name (optional)", text: $lastName)
                .textContentType(.familyName)
                .autocapitalization(.words)
        }
    }
    
    private var personalSection: some View {
        Section("Personal details") {
            DatePicker("Date of birth (optional)", selection: $dateOfBirth, displayedComponents: .date)
            Picker("Gender (optional)", selection: $selectedGender) {
                Text("Male").tag(Gender.male)
                Text("Female").tag(Gender.female)
            }
        }
    }
    
    private var buttonSection: some View {
        VStack(spacing: 12) {
            Button {
                Task { await saveProfile() }
            } label: {
                ZStack {
                    Text(isSaving ? "Saving..." : "Save Profile")
                        .opacity(isSaving ? 0 : 1)
                    if isSaving {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
            }
            .buttonStyle(.glassProminent)
            .disabled(isSaving || !canSave)

            NavigationLink { OnboardingCompletedView() } label: {
                Text("Not now")
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
    }
    
    private func onImageSelectorPressed() {
        // Show the image picker sheet for selecting a profile image
        isImagePickerPresented = true
    }

    private func prefillFromCurrentUser() {
        guard let user = userManager.currentUser else { return }
        firstName = user.firstName ?? firstName
        lastName = user.lastName ?? lastName
        if let existingEmail = user.email { email = existingEmail }
        if let dob = user.dateOfBirth { dateOfBirth = dob }
        if let gender = user.gender { selectedGender = gender }
    }
    
    private func saveProfile() async {
        guard canSave else { return }
        isSaving = true
        
        do {
            guard let userId = userManager.currentUser?.userId else {
                logManager.trackEvent(eventName: "profile_save_failed", parameters: ["error": "Missing current user ID"])
                return
            }

            let trimmedFirst = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedLast = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

            let user = UserModel(
                userId: userId,
                email: trimmedEmail.isEmpty ? userManager.currentUser?.email : trimmedEmail,
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

            logManager.trackEvent(eventName: "profile_save_success")
            // Proceed to health data step; onboarding completion is finalized on the last step
            navigateNext = true
        } catch {
            logManager.trackEvent(eventName: "profile_save_failed", parameters: ["error": String(describing: error)])
        }
        isSaving = false
    }
}

#Preview("Functioning") {
    NavigationStack {
        OnboardingCreateProfileView()
    }
    .environment(UserManager(services: MockUserServices(user: .mock)))
    .previewEnvironment()
}

#Preview("Slow Loading") {
    NavigationStack {
        OnboardingCreateProfileView()
    }
    .environment(UserManager(services: MockUserServices(user: .mock, delay: 3)))
    .previewEnvironment()
}

#Preview("Upload Failure") {
    NavigationStack {
        OnboardingCreateProfileView()
    }
    .environment(UserManager(services: MockUserServices(user: .mock, delay: 1, showError: true)))
    .previewEnvironment()
}
