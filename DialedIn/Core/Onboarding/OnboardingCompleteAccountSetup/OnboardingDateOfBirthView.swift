//
//  OnboardingDateOfBirthView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingDateOfBirthView: View {
    @Environment(DependencyContainer.self) private var container

    let gender: Gender
    @State private var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    
    @State private var navigationDestination: NavigationDestination?

    enum NavigationDestination {
        case height(gender: Gender, dateOfBirth: Date)
    }
    
    #if DEBUG || MOCK
    @State private var showDebugView: Bool = false
    #endif
    
    var body: some View {
        List {
            DatePicker(selection: $dateOfBirth, displayedComponents: .date) {
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
                if case .height = navigationDestination { return true }
                return false
            },
            set: { if !$0 { navigationDestination = nil } }
        )) {
            if case let .height(gender, dateOfBirth) = navigationDestination {
                OnboardingHeightView(gender: gender, dateOfBirth: dateOfBirth)
            } else {
                EmptyView()
            }
        }
        #if DEBUG || MOCK
        .sheet(isPresented: $showDebugView) {
            DevSettingsView(viewModel: DevSettingsViewModel(container: container))
        }
        #endif
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
            NavigationLink {
                OnboardingHeightView(gender: gender, dateOfBirth: dateOfBirth)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingDateOfBirthView(gender: .male)
    }
    .previewEnvironment()
}
