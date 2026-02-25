import SwiftUI
import PhotosUI

struct AccountDelegate {
    var eventParameters: [String: Any]? {
        nil
    }
}

struct AccountView: View {
    
    @State var presenter: AccountPresenter
    let delegate: AccountDelegate
    
    var body: some View {
        List {
            imageSection
            profileSection
            dataManagementSection
            securitySection
        }
        .ignoresSafeArea(edges: .top)
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .photosPicker(isPresented: $presenter.isImagePickerPresented, selection: $presenter.selectedPhotoItem, matching: .images)
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
        .toolbar {
            toolbarContent
        }
        .onAppear {
            presenter.onViewAppear(delegate: delegate)
        }
        .onDisappear {
            presenter.onViewDisappear(delegate: delegate)
        }
    }

    private var imageSection: some View {
        Section {
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
                } else if let profileImageUrl = presenter.currentUser?.submittedProfileImage {
                    // Use cached image
                    ImageLoaderView(urlString: profileImageUrl)
                } else {
                    ImageLoaderView()
                }
            }
            .frame(height: 200)
            .removeListRowFormatting()
        }
        .listSectionMargins(.top, 0)
        .listSectionMargins(.horizontal, 0)
    }

    private var profileSection: some View {
        Section("Profile") {
            CustomLabelButtonView(
                symbolName: "person.fill",
                title: "Name",
                subtitle: "\(presenter.firstName) \(presenter.lastName)",
                content: {
                    Text("Edit")
                        .padding(.horizontal, 8)
                        .padding(8)
                        .background(Color.secondary.opacity(0.2), in: .capsule)
                        .anyButton(.press) {
                            print("Edit name pressed")
                        }
                }
            )

            DatePicker("Date of birth", selection: $presenter.dateOfBirth, displayedComponents: .date)
            Picker(selection: $presenter.selectedGender) {
                Text("Not specified").tag(nil as Gender?)
                Text("Male").tag(Gender.male as Gender?)
                Text("Female").tag(Gender.female as Gender?)
            } label: {
                Text("Gender")
                    .fontWeight(.semibold)
            }
            if let height = presenter.currentUser?.submittedHeightCentimeters {
                rowItem(title: "Height", subtitle: "\(height)", action: {
                    print("Edit height pressed")
                })
            }

            if let cardioExperience = presenter.currentUser?.submittedCardioFitnessLevel {
                rowItem(title: "Cardio Experience", subtitle: "\(cardioExperience)", action: {
                    print("Edit cardio experience pressed")
                })
            }

            if let liftingExperience = presenter.currentUser?.submittedExerciseFrequency {
                rowItem(title: "Lifting Experience", subtitle: "\(liftingExperience)", action: {
                    print("Edit lifting experience pressed")
                })
            }
        }
    }

    private var securitySection: some View {
        Section {
            rowItem(title: "Email", subtitle: presenter.currentUser?.email, action: {
                print("Edit Email Pressed")
            })
            rowItem(title: "Password", subtitle: "********", action: {
                print("Edit Password Pressed")
            })
            Text("Log Out")
                .anyButton {
                    presenter.onSignOutPressed()
                }
            Button(role: .destructive) {
                presenter.onDeleteAccountPressed()
            } label: {
                Text("Delete Account")
            }
        } header: {
            Text("Security")
        }
    }

    private var dataManagementSection: some View {
        Section {
            Label("Data Export", systemImage: "square.and.arrow.up")
                .anyButton(.highlight) {
                    
                }
            Label("Data Visibility", systemImage: "eye")
                .anyButton(.highlight) {
                    presenter.onDataVisibilityPressed()
                }
        } header: {
            Text("Data Management")
        }
    }

    private func rowItem(title: String, subtitle: String? = nil, action: @escaping () -> Void) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                if let subtitle {
                    Text(subtitle)
                }
            }
            Spacer()
            Text("Edit")
                .padding(4)
                .padding(.horizontal, 4)
                .background(.secondary.opacity(0.2), in: .capsule)
                .anyButton(.highlight) {
                    action()
                }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                presenter.presentImagePicker()
            } label: {
                Image(systemName: presenter.currentUser?.submittedProfileImage == nil ? "photo.badge.plus" : "photo.badge.checkmark")
            }
        }
    }

}

#Preview {
    let container = DevPreview.shared.container()
    let interactor = CoreInteractor(container: container)
    let builder = CoreBuilder(interactor: interactor)
    let delegate = AccountDelegate()
    
    return RouterView { router in
        builder.accountView(router: router, delegate: delegate)
    }
}

extension CoreBuilder {
    
    func accountView(router: AnyRouter, delegate: AccountDelegate) -> some View {
        AccountView(
            presenter: AccountPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            ),
            delegate: delegate
        )
    }
    
}

extension CoreRouter {
    
    func showAccountView(delegate: AccountDelegate) {
        router.showScreen(.push) { router in
            builder.accountView(router: router, delegate: delegate)
        }
    }
    
}
