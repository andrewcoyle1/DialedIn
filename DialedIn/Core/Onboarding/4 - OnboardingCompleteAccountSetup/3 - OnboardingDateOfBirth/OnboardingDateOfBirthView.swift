//
//  OnboardingDateOfBirthView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 04/10/2025.
//

import SwiftUI
import CustomRouting

struct OnboardingDateOfBirthViewDelegate {
    var userModelBuilder: UserModelBuilder

}
struct OnboardingDateOfBirthView: View {

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
                viewModel.navigateToOnboardingHeight(userBuilder: delegate.userModelBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
        }
    }
}

#Preview {
    let builder = CoreBuilder(container: DevPreview.shared.container)
    RouterView { router in
        builder.onboardingDateOfBirthView(
            router: router,
            delegate: OnboardingDateOfBirthViewDelegate(
                userModelBuilder: UserModelBuilder.dobMock
            )
        )
    }
    .previewEnvironment()
}
