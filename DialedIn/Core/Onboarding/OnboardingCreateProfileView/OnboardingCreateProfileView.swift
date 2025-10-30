//
//  OnboardingCreateProfileView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 24/09/2025.
//

import SwiftUI
import PhotosUI

struct OnboardingCreateProfileView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingCreateProfileViewModel
    @Binding var path: [OnboardingPathOption]

    var body: some View {
        List {
            imageSection
            profileSection
            personalSection
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Create a Profile")
        .navigationBarTitleDisplayMode(.large)
        .screenAppearAnalytics(name: "OnboardingCreateProfile")
        #if !DEBUG && !MOCK
        .navigationBarBackButtonHidden(true)
        #else
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.showDebugView = true
                } label: {
                    Image(systemName: "info")
                }
            }
        }
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
        .onAppear(perform: viewModel.prefillFromCurrentUser)
        .safeAreaInset(edge: .bottom) {
            buttonSection
        }
        .onChange(of: viewModel.selectedPhotoItem) {
            Task {
                await viewModel.handlePhotoSelection()
            }
        }
    }
    
    private var imageSection: some View {
        Section("Profile photo") {
            HStack {
                Spacer()
                Button {
                    viewModel.onImageSelectorPressed()
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
                .photosPicker(isPresented: $viewModel.isImagePickerPresented, selection: $viewModel.selectedPhotoItem, matching: .images)
            Spacer()
            }
        }
        .removeListRowFormatting()
    }
    
    private var profileSection: some View {
        Section("Profile") {
            TextField("First name", text: $viewModel.firstName)
                .textContentType(.givenName)
                .autocapitalization(.words)
            TextField("Last name (optional)", text: $viewModel.lastName)
                .textContentType(.familyName)
                .autocapitalization(.words)
        }
    }
    
    private var personalSection: some View {
        Section("Personal details") {
            DatePicker("Date of birth (optional)", selection: $viewModel.dateOfBirth, displayedComponents: .date)
            Picker("Gender (optional)", selection: $viewModel.selectedGender) {
                Text("Male").tag(Gender.male)
                Text("Female").tag(Gender.female)
            }
        }
    }
    
    private var buttonSection: some View {
        VStack(spacing: 12) {
            Button {
                Task { await viewModel.saveProfile(path: $path) }
            } label: {
                ZStack {
                    Text(viewModel.isSaving ? "Saving..." : "Save Profile")
                        .opacity(viewModel.isSaving ? 0 : 1)
                    if viewModel.isSaving {
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
            }
            .buttonStyle(.glassProminent)
            .disabled(viewModel.isSaving || !viewModel.canSave)

            Button {
                viewModel.markOnboardingComplete()
            } label: {
                Text("Not now")
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom)
        }
        .padding(.horizontal)
    }
}

#Preview("Functioning") {
    @Previewable @State var path: [OnboardingPathOption] = []
    NavigationStack {
        OnboardingCreateProfileView(
            viewModel: OnboardingCreateProfileViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                )
            ), path: $path
        )
    }
    .previewEnvironment()
}
