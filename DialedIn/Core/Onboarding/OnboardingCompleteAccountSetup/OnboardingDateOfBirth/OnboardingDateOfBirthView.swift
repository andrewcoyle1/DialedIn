//
//  OnboardingDateOfBirthView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingDateOfBirthView: View {
    @Environment(DependencyContainer.self) private var container
    @State var viewModel: OnboardingDateOfBirthViewModel

    var body: some View {
        List {
            DatePicker(selection: $viewModel.dateOfBirth, displayedComponents: .date) {
                Text("When were you born?")
                    .foregroundStyle(Color.secondary)
            }
            .removeListRowFormatting()
        }
        .navigationTitle("Date of birth")
        .toolbar {
            toolbarContent
        }
        .navigationDestination(isPresented: Binding(
            get: {
                if case .height = viewModel.navigationDestination { return true }
                return false
            },
            set: { if !$0 { viewModel.navigationDestination = nil } }
        )) {
            if case let .height(gender, dateOfBirth) = viewModel.navigationDestination {
                OnboardingHeightView(
                    viewModel: OnboardingHeightViewModel(
                        interactor: CoreInteractor(
                            container: container
                        ),
                    gender: gender,
                    dateOfBirth: dateOfBirth
                    )
                )
            } else {
                EmptyView()
            }
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(interactor: CoreInteractor(container: container)))
        }
        #endif
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
            NavigationLink {
                OnboardingHeightView(
                    viewModel: OnboardingHeightViewModel(
                        interactor: CoreInteractor(
                            container: container
                        ),
                        gender: viewModel.gender,
                        dateOfBirth: viewModel.dateOfBirth
                    )
                )
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingDateOfBirthView(
            viewModel: OnboardingDateOfBirthViewModel(
                interactor: CoreInteractor(
                    container: DevPreview.shared.container
                ),
                gender: .male
            )
        )
    }
    .previewEnvironment()
}
