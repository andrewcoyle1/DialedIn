//
//  OnboardingDateOfBirthView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI

struct OnboardingDateOfBirthViewDelegate {
    var path: Binding<[OnboardingPathOption]>
    var userModelBuilder: UserModelBuilder

}
struct OnboardingDateOfBirthView: View {

    @Environment(CoreBuilder.self) private var builder

    @State var viewModel: OnboardingDateOfBirthViewModel

    var delegate: OnboardingDateOfBirthViewDelegate

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
        #if DEBUG || MOCK
        .sheet(isPresented: $viewModel.showDebugView) {
            builder.devSettingsView()
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
            Button {
                viewModel.navigateToOnboardingHeight(path: delegate.path, userBuilder: delegate.userModelBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    @Previewable @State var path: [OnboardingPathOption] = []
    let builder = CoreBuilder(container: DevPreview.shared.container)
    NavigationStack(path: $path) {
        builder.onboardingDateOfBirthView(
            delegate: OnboardingDateOfBirthViewDelegate(
                path: $path,
                userModelBuilder: UserModelBuilder.dobMock
            )
        )
    }
    .navigationDestinationOnboardingModule(path: $path)
    .previewEnvironment()
}
