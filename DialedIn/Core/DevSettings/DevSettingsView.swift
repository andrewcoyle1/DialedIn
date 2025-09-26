//
//  DevSettingsView.swift
//  AIChatCourse
//
//  Created by Andrew Coyle on 10/22/24.
//
import SwiftUI
import SwiftfulUtilities

struct DevSettingsView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(ExerciseTemplateManager.self) private var exerciseTemplateManager
    @Environment(AppState.self) private var appState

    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                authSection
                userSection
                deviceSection
                exerciseTemplateSection
                debugActionsSection
            }
            .navigationTitle("Dev Settings 🫨")
            .screenAppearAnalytics(name: "DevSettings")
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButtonView
                }
            }
        }
    }
    
    private var backButtonView: some View {
        Image(systemName: "xmark")
            .anyButton {
                onBackButtonPressed()
            }
    }
    
    private func onBackButtonPressed() {
        dismiss()
    }
    
    private var authSection: some View {
        Section {
            let array = authManager.auth?.eventParameters.asAlphabeticalArray ?? []
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Auth Info")
        }
    }
    
    private var userSection: some View {
        Section {
            let array = userManager.currentUser?.eventParameters.asAlphabeticalArray ?? []
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("User Info")
        }
    }
    
    private var deviceSection: some View {
        Section {
            let array = Utilities.eventParameters.asAlphabeticalArray
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
        } header: {
            Text("Device Info")
        }
    }
    
    private var exerciseTemplateSection: some View {
        Section {
            let array = (try? exerciseTemplateManager.getAllLocalExerciseTemplates()) ?? []
            ForEach(array, id: \.exerciseId) { item in
                CustomListCellView(imageName: item.imageURL, title: item.name, subtitle: item.description)
                    .removeListRowFormatting()
            }
        } header: {
            Text("Exercise Templates")
        }
    }
    
    @ViewBuilder
    private var debugActionsSection: some View {
        #if DEBUG
        Section {
            Button(role: .destructive) {
                defer {
                    onForceFreshAnonUser()
                }
                dismiss()
            } label: {
                Text("Force fresh anonymous user")
            }
            .tint(.red)
        } header: {
            Text("Debug Actions")
        }
        #endif
    }
    
    private func itemRow(item: (key: String, value: Any)) -> some View {
        HStack {
            Text(item.key)
            Spacer(minLength: 4)
            
            if let value = String.convertToString(item.value) {
                Text(value)
            } else {
                Text("Unknown")
            }
        }
        .font(.caption)
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
    
    #if DEBUG
    private func onForceFreshAnonUser() {
        Task {
            // Attempt account deletion first; if that fails, sign out
            do {
                try await authManager.deleteAccount()
            } catch {
                try? authManager.signOut()
            }
            // Clear local user cache
            userManager.clearAllLocalData()
            // Reset UI back to onboarding
            await MainActor.run {
                appState.updateViewState(showTabBarView: false)
            }
        }
    }
    #endif
}

#Preview {
    DevSettingsView()
        .previewEnvironment()
}
