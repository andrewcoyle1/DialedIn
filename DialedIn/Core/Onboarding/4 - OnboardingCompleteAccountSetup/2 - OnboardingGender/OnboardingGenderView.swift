//
//  OnboardingGenderView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingGenderView: View {

    @Environment(\.dismiss) private var dismiss

    @State var viewModel: OnboardingGenderViewModel

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    genderRow(.male)
                    genderRow(.female)
                }
                .removeListRowFormatting()
                .padding(.horizontal)
            } header: {
                Text("Select your gender")
            }
        }
        .navigationTitle("About You")
        .screenAppearAnalytics(name: "OnboardingSelectGender")
        .toolbar {
            toolbarContent
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                viewModel.navigateToDateOfBirth()
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(!viewModel.canSubmit)
        }
    }
    
    private func genderRow(_ gender: Gender) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(gender.description)
                    .font(.headline)
            }
            Spacer(minLength: 8)
            Image(systemName: viewModel.selectedGender == gender ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(viewModel.selectedGender == gender ? Color.accent : Color.secondary)
        }
        .contentShape(Rectangle())
        .anyButton(.press) {
            viewModel.selectedGender = gender
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingGenderView(router: router)
    }
    .previewEnvironment()
}
