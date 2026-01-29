//
//  OnboardingTrainingEquipmentView.swift
//  DialedIn
//
//  Created by Andrew Coyle on 10/31/25.
//

import SwiftUI
import SwiftfulRouting

struct OnboardingTrainingEquipmentView: View {

    @State var presenter: OnboardingTrainingEquipmentPresenter

    var delegate: OnboardingTrainingEquipmentDelegate

    var body: some View {
        List {
            Section {
                ForEach(EquipmentType.allCases) { equipment in
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: equipment.systemImage)
                            .foregroundStyle(.accent)
                            .frame(width: 24)
                        Text(equipment.description)
                            .font(.headline)
                        Spacer()
                        Toggle(
                            "",
                            isOn: Binding(
                                get: { presenter.selectedEquipment.contains(equipment) },
                                set: { isOn in
                                    if isOn {
                                        presenter.selectedEquipment.insert(equipment)
                                    } else {
                                        presenter.selectedEquipment.remove(equipment)
                                    }
                                }
                            )
                        )
                    }
                }
            } header: {
                Text("Select all equipment you have access to.")
            } footer: {
                Text("This helps us recommend the best program for you.")
            }
        }
        .navigationTitle("Available Equipment")
        .toolbar {
            toolbarContent
        }
        .screenAppearAnalytics(name: "TrainingEquipment")
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if DEBUG || MOCK
        ToolbarItem(placement: .topBarLeading) {
            Button {
                presenter.onDevSettingsPressed()
            } label: {
                Image(systemName: "info")
            }
        }
        #endif
        
        ToolbarSpacer(.flexible, placement: .bottomBar)
        ToolbarItem(placement: .bottomBar) {
            Button {
                presenter.navigateToReview(builder: delegate.trainingProgramBuilder)
            } label: {
                Image(systemName: "chevron.right")
            }
            .buttonStyle(.glassProminent)
            .disabled(presenter.selectedEquipment.isEmpty)
        }
    }
}

extension OnbBuilder {
    func onboardingTrainingEquipmentView(router: AnyRouter, delegate: OnboardingTrainingEquipmentDelegate) -> some View {
        OnboardingTrainingEquipmentView(
            presenter: OnboardingTrainingEquipmentPresenter(interactor: interactor, router: OnbRouter(router: router, builder: self)),
            delegate: delegate
        )
    }
}

extension OnbRouter {
    func showOnboardingTrainingEquipmentView(delegate: OnboardingTrainingEquipmentDelegate) {
        router.showScreen(.push) { router in
            builder.onboardingTrainingEquipmentView(router: router, delegate: delegate)
        }
    }
}

#Preview {
    let builder = OnbBuilder(interactor: OnbInteractor(container: DevPreview.shared.container()))
    RouterView { router in
        builder.onboardingTrainingEquipmentView(
            router: router, 
            delegate: OnboardingTrainingEquipmentDelegate(
                trainingProgramBuilder: TrainingProgramBuilder()
            )
        )
    }
    .previewEnvironment()
}
